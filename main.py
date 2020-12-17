# This Python file uses the following encoding: utf-8
import sys
import os
from PySide2.QtGui import QGuiApplication, QIcon
from PySide2.QtQml import QQmlApplicationEngine
from redux import Redux

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    QGuiApplication.setWindowIcon(QIcon("res/icon/blackhole_128px.ico"))
    engine = QQmlApplicationEngine()
    redux = Redux()
    engine.rootContext().setContextProperty('redux', redux)

    engine.load(os.path.join(os.path.dirname(__file__), "main.qml"))
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec_())
