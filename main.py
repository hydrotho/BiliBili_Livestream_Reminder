import asyncio
import logging
import os
import sys

import requests
import typer
import yaml
from telegram import Bot, InlineKeyboardButton, InlineKeyboardMarkup

import blivedm.blivedm as blivedm

logger = logging.getLogger("BiliBili_Livestream_Reminder")

bot_token = ""
chat_id = ""

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36"
}


def get_live_room_info(room_id):
    url = f"https://api.live.bilibili.com/room/v1/Room/get_info?room_id={room_id}"
    response = requests.get(url, headers=HEADERS)
    if response.status_code != 200:
        logger.error("获取直播间信息失败: HTTP 状态码 %s", response.status_code)
        return None
    data = response.json()
    if data["code"] != 0:
        logger.error("获取直播间信息失败: %s", data["message"])
        return None
    return data["data"]


def get_user_info(uid):
    url = f"https://api.live.bilibili.com/live_user/v1/Master/info?uid={uid}"
    response = requests.get(url, headers=HEADERS)
    if response.status_code != 200:
        logger.error("获取用户信息失败: HTTP 状态码 %s", response.status_code)
        return None
    data = response.json()
    if data["code"] != 0:
        logger.error("获取用户信息失败: %s", data["message"])
        return None
    return data["data"]


async def send_telegram_message(live_room_info, user_info):
    bot = Bot(bot_token)
    caption = f"[{user_info['info']['uname']}](https://space.bilibili.com/{user_info['info']['uid']}) 直播中\n标题：{live_room_info['title']}"
    keyboard = [
        [
            InlineKeyboardButton(
                "直播间", url=f"https://live.bilibili.com/{live_room_info['room_id']}"
            )
        ]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await bot.send_photo(
        chat_id=chat_id,
        photo=live_room_info["user_cover"],
        caption=caption,
        reply_markup=reply_markup,
        parse_mode="Markdown",
    )


class LiveRoom:
    def __init__(self, room_id):
        self.room_id = room_id
        self.is_live = False

    def on_preparing(self):
        self.is_live = False

    async def on_live(self):
        if self.is_live:
            return
        self.is_live = True
        live_room_info = get_live_room_info(self.room_id)
        if live_room_info is None:
            return
        user_info = get_user_info(live_room_info["uid"])
        if user_info is None:
            return
        await send_telegram_message(live_room_info, user_info)


class MyHandler(blivedm.BaseHandler):
    def __init__(self):
        self.rooms = {}

    def add_room(self, room_id):
        self.rooms[room_id] = LiveRoom(room_id)

    def _on_preparing(self, client: blivedm.BLiveClient, _):
        room = self.rooms.get(client.room_id)
        if room:
            room.on_preparing()

    def _on_live(self, client: blivedm.BLiveClient, _):
        room = self.rooms.get(client.room_id)
        if room:
            asyncio.create_task(room.on_live())

    _CMD_CALLBACK_DICT = blivedm.BaseHandler._CMD_CALLBACK_DICT.copy()
    _CMD_CALLBACK_DICT["PREPARING"] = _on_preparing
    _CMD_CALLBACK_DICT["LIVE"] = _on_live


async def reminder(room_ids):
    handler = MyHandler()
    for room_id in room_ids:
        handler.add_room(room_id)

    clients = [blivedm.BLiveClient(room_id) for room_id in room_ids]
    for client in clients:
        client.set_handler(handler)
        client.start()

    try:
        await asyncio.gather(*(client.join() for client in clients))
    finally:
        await asyncio.gather(*(client.stop_and_close() for client in clients))


def main(
    config: str = "config.yaml",
):
    global bot_token, chat_id

    if not os.path.isabs(config):
        base_path = os.path.dirname(sys.argv[0])
        config = os.path.join(base_path, config)

    with open(config, "r") as file:
        c = yaml.safe_load(file)
    bot_token = c["telegram-bot-token"]
    chat_id = c["telegram-chat-id"]
    room_ids = c["room-ids"]

    asyncio.run(reminder(room_ids))


if __name__ == "__main__":
    typer.run(main)
