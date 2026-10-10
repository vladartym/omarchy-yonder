// Yonder in the Omarchy bar. Every 3 seconds `yonder status` gives Waybar-style JSON from the Yonder bridge: the
// icon and the agents that run (3), wait on the user (?1) or have new results (✓2). The class "active" lights it
// during a call. Left click starts or ends the call, right click opens Yonder, middle click pairs a phone.
//
// The widget runs only the `yonder` command of the Yonder installer, by its absolute path and with argv, never
// through a shell.

import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var bar: null
  property string moduleName: ""
  property var settings: ({})

  readonly property string yonder: Quickshell.env("HOME") + "/.local/bin/yonder"
  readonly property int barSize: bar && bar.barSize ? bar.barSize : 26

  readonly property string icon: String.fromCodePoint(0xF036C)
  property string label: icon
  property string tip: "Yonder"
  property bool live: false

  // The JSON comes from the local bridge. The bounds keep one bad line out of the bar all the same.
  function plain(value, max) {
    return typeof value === "string" ? value.replace(/[\u0000-\u0008\u000b-\u001f\u007f]/g, " ").slice(0, max) : ""
  }

  function apply(output) {
    if (output.length > 4096) return
    try {
      const data = JSON.parse(output)
      root.label = plain(data.text, 40) || root.icon
      root.tip = plain(data.tooltip, 300) || "Yonder"
      root.live = data.class === "active"
    } catch (e) {
      root.label = root.icon + " !"
      root.tip = "Yonder is not installed. Get it at yonder.so."
      root.live = false
    }
  }

  function run(args) {
    Quickshell.execDetached([root.yonder].concat(args))
  }

  readonly property bool vertical: bar ? bar.vertical === true : false

  implicitWidth: vertical ? root.barSize : glyph.implicitWidth + 8
  implicitHeight: vertical ? glyph.implicitHeight + 8 : root.barSize

  Process {
    id: status
    command: [root.yonder, "status"]
    stdout: StdioCollector {
      onStreamFinished: root.apply(this.text)
    }
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!status.running) status.running = true
  }

  Text {
    id: glyph
    anchors.centerIn: parent
    text: root.vertical ? root.icon : root.label
    textFormat: Text.PlainText
    color: root.live ? "#e5484d" : (root.bar && root.bar.foreground ? root.bar.foreground : "white")
    font.family: root.bar && root.bar.fontFamily ? root.bar.fontFamily : "monospace"
    font.pixelSize: 12
  }

  // The bar shows the tooltip only while its target says that it is hovered.
  readonly property bool tooltipHovered: pointer.containsMouse
  onTooltipHoveredChanged: if (bar) tooltipHovered ? bar.showTooltip(root, tip) : bar.hideTooltip(root)

  // The bar takes the left click on a module and calls this, as for its own buttons. The right and the middle click
  // come through the MouseArea. The registration gives the hand pointer of the bar.
  property var registeredBar: null
  onBarChanged: {
    if (registeredBar) registeredBar.unregisterClickTarget(root)
    registeredBar = bar
    if (bar) bar.registerClickTarget(root)
  }
  Component.onDestruction: if (registeredBar) registeredBar.unregisterClickTarget(root)
  function triggerPress(button) {
    if (bar) bar.hideTooltip(root)
    if (button === Qt.RightButton) run(["open"])
    else if (button === Qt.MiddleButton) Quickshell.execDetached(["/usr/bin/xdg-terminal-exec", yonder, "pair", "--hold"])
    else run(["call"])
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    onClicked: function (mouse) { root.triggerPress(mouse.button) }
  }
}
