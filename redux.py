# This Python file uses the following encoding: utf-8
import os
import subprocess
import threading
import time
import yaml
from PySide2.QtCore import Slot, QObject, QModelIndex, QAbstractListModel
from loguru import logger

class Redux(QObject):
    wormhole = "wormhole"
    config_path="./config.yaml"

    def __init__(self, ) -> None:
        super().__init__()
        self.config={}
        self.messages = []
        self.single_message=""
        self.sub_program = None
        self.display_obj=None
        self.init_config()
        if self._is_command_valid:
            logger.info("start")
            self("stop")
            self.check_start("init")
            self.listen_log()
            os.system(f"chmod u+x {self.wormhole}")
            self("set log_lever=error")


    def __del__(self):
        logger.info("del")
        # self.sub_program.kill()

    def __call__(self, *args):
        for arg in args:
            cmd = f"{self.wormhole}  {arg}"
            os.system(cmd)

    def init_config(self):
        if os.path.exists(self.config_path):
            with open(self.config_path)as f:
                config=yaml.safe_load(f)
                self.wormhole=config["wormhole"]
        else:
            self.config["wormhole"]=self.wormhole
            self.write_config()

    def write_config(self):
        with open(self.config_path,'w')as f:
            yaml.safe_dump(self.config,f)

    @property
    def _is_command_valid(self):
        result = os.popen(f"{self.wormhole} env").readlines()
        if len(result)>0:
            return True
        return False

    @property
    def envs(self):
        envs={}
        result = os.popen(f"{self.wormhole} env").readlines()
        for line in result:
            sp=line.split(":")
            envs[sp[0]]=sp[1].strip()
        return envs

    @Slot(QObject)
    def set_name(self,obj):
        envs = self.envs
        name=envs["self_name"]
        obj.setProperty("text",name)

    @Slot(QObject)
    def set_ip(self,obj):
        envs = self.envs
        ip=envs["self_host"]
        obj.setProperty("text",ip)

    @property
    def is_online(self):
        result = os.popen(f"{self.wormhole} check").readlines()
        if len(result)>0 and result[0] == "1":
            return True
        return False

    def check_start(self,name=""):
        logger.debug(f"check_start for {name}")
        if self.sub_program is None:
            self.sub_program = subprocess.Popen(f"{self.wormhole} server", shell=True, stdout=subprocess.PIPE)

    def get_devices(self):
        self.check_start("get_device")
        result = os.popen(f"{self.wormhole} ls").readlines()
        if len(result) > 3:
            titles = []
            devices = []
            title_line = result[1]
            title_sp = title_line.split("|")
            for title_name in title_sp:
                title = title_name.strip().lower()
                if title != "":
                    titles.append(title)
            lines = result[3:-1]
            for line in lines:
                sp = line.split("|")
                device = {}
                offset = 0
                for i, title in enumerate(titles):
                    item = sp[i + offset].strip().lower()
                    if item == "":
                        offset += 1
                        continue
                    if "online" in item:
                        item = "online"
                    elif "offline" in item:
                        item = "offline"
                    device[title] = item
                devices.append(device)
            return devices
        return []

    @Slot(QObject)
    def get_online_devices(self, obj):
        devices = []
        devices_all = self.get_devices()
        for device in devices_all:
            if "state" in device and device["state"] == "online":
                devices.append(device)
        obj.setProperty("model", MyListModel(devices))

    @Slot(str)
    def add_net(self,ip:str):
        self.check_start("add net")
        cmd = f"add {ip}"
        logger.debug(cmd)
        self(cmd)

    @Slot(str)
    def change_name(self,name:str):
        self.check_start("change name")
        cmd = f"set self_name={name}"
        logger.debug(cmd)
        self(cmd)
        self("restart")

    def parse_command(self,command):
        if len(command)>6 and command[:3]=="set":
            self(command)
        else:
            sp=command.split("=")
            if len(sp)==1:
                if sp[0]=="clear":
                    self.single_message=""
                    self.display_obj.setProperty("text",self.single_message)
            if len(sp)==2:
                if sp[0]=="wormhole":
                    self.wormhole=sp[1]
                    self.config["wormhole"]=self.wormhole
                    self.write_config()


    @Slot(str, str, result=None)
    def send(self, target: str, message: str):

        if len(message)==0:
            logger.debug("The action that send None was filtrated")
            return
        if message[0]=="!":
            self.parse_command(message[1:])
            return
        if target==0 or target=="0":
            logger.debug("The action that send to self was filtrated")
            return


        if target.count(".") == 3:
            target += ":1883"

        cmd = f"send {target} {message}"
        logger.debug(cmd)
        self.check_start("send")
        self(cmd)

    # @Slot(QObject)
    # def clear_message(self,obj):
    #     self.single_message=""
    #     obj.setProperty("text",self.single_message)

    @Slot(QObject)
    def get_message(self,obj):
        # single_message=""
        # for message in self.messages:
        #     single_message+="\n"+message
        # obj.setProperty("text",single_message)
        obj.setProperty("text",self.single_message)
        if self.display_obj is None:
            self.display_obj=obj

    def listen_log(self):
        self.check_start("listen log")
        i=0
        while self.sub_program is None:
            time.sleep(1)
            i+=1
            print(i)
        def f(self):
            while self.sub_program.poll() is None:
                line = self.sub_program.stdout.readline()
                if line:
                    ms=line.decode()
                    logger.info(f"#Subprogram event: {ms}")
                    self.single_message=f"{self.single_message}\n{ms}"
                    # self.messages.append(ms)
        thread = threading.Thread(target = f,args=(self,),daemon=False)
        thread.start()

    @Slot()
    def exit(self):
        logger.info("exit")
        self("stop")
        self.sub_program.kill()


class MyListModel(QAbstractListModel):
    UserRole = 0x100
    HOST = UserRole + 0
    NAME = UserRole + 1

    def __init__(self, model):
        """
        :param model: a list of persons. e.g. [{'name': 'Li Ming', 'age': 20},]
        """
        super().__init__()
        self.model = model

    # 必须覆写 rowCount(), data() 方法.
    def rowCount(self, parent=None) -> int:
        return len(self.model)

    def roleNames(self):
        return {
            self.HOST: b'host',  # 此处的 b'name' 是指 QML 中的 name. 特别注意的
            # 是必须是 bytes 类型, 而不是 str 类型.
            self.NAME: b'name',
        }

    def data(self, index: QModelIndex, role: int = None):
        """
        QML.ListView 会从这个方法取数据, role 相当于 QML.ListView 请求的 "键",
        我们需要根据 "键" 返回相对应的 "值".

        :param index: 特别注意, 这个是 QModelIndex 类型. 通过 QModelIndex.row()
            可以获得 int 类型的位置. 这个位置是列表元素在列表中的序号, 从 0 开始
            数.
        :param role:
        :return:
        """
        index = index.row()
        row: dict = self.model[index]
        if role == self.HOST:
            return row['host']
        elif role == self.NAME:
            return row['name']


if __name__ == '__main__':
    def f():
        pass
    thread = threading.Thread(target = f)
    thread.start()
