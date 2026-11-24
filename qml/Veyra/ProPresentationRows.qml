// Professional-view reusable presentation component.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Effects

ColumnLayout {
    id: presentationRows
    readonly property var profileTools: ("nvidiaVrrProfile" in veyra) ? veyra.nvidiaVrrProfile : null
    Layout.fillWidth: true
    spacing: 0
    VRow {
        label: "Gaming BR · PS5"
        hintBelow: true
        hint: "GTX 1660 Ti: comece em 2× e aumente somente se a GPU mantiver a cadência. RIFE 4×–6× experimental; use SDR."
        VButton {
            text: "Perfil competitivo"
            onClicked: {
                veyra.setPreference("language", "pt-BR")
                veyra.fgEnabled = false
                veyra.nrEnabled = false
                veyra.srEnabled = false
                veyra.videoHdr = false
                veyra.displaySync = 2
                veyra.fgLowQueue = true
                veyra.outputCustomFps = 120
                veyra.outputRateMode = 2
            }
        }
    }
    VRow {
        label: "Limite rápido de FPS"
        enabled: !veyra.presentationOwned
        VSeg {
            options: [{id:"60",label:"60"},{id:"120",label:"120"},{id:"144",label:"144"},{id:"172",label:"172"}]
            current: veyra.outputRateMode === 2 ? String(veyra.outputCustomFps) : ""
            onPicked: id => { veyra.outputCustomFps = Number(id); veyra.outputRateMode = 2 }
        }
    }
    VRow {
        label: "Qualidade QHD · 1440p"
        hintBelow: true
        hint: "NVIDIA NIS: upscaling espacial com nitidez, sem exigir GPU RTX. Pode aumentar o custo do RIFE."
        VButton {
            text: "Ativar NIS 1440p"
            enabled: veyra.effectCapabilities["sr24"] && veyra.effectCapabilities["sr24"].available
            onClicked: {
                veyra.videoSrQuality = 24
                veyra.srTargetIndex = 1
                if (!veyra.srEnabled) veyra.addEffect("sr")
                veyra.srEnabled = true
            }
        }
    }
    VRow {
        label: "RIFE · quadros gerados"
        hintBelow: true
        hint: "Requer runtime RIFE. O limite de FPS continua independente."
        VButton {
            text: "Ativar RIFE 2×"
            enabled: veyra.effectCapabilities["rife"] && veyra.effectCapabilities["rife"].available
            onClicked: {
                veyra.videoHdr = false
                if (veyra.addEffect("rife-fg") >= 0) {
                    veyra.fgBackendName = "rife"
                    veyra.fgAutoMultiplierEnabled = false
                    veyra.fgAdaptive = false
                    veyra.fgMultiplier = 2
                }
            }
        }
    }
    VRow {
        label: qsTr("显示同步")
        // The explanation is long; keep it under the row so a short option strip
        // does not squeeze it into a narrow column beside the control.
        hintBelow: true
        hint: qsTr("自动（推荐）：不撕裂，也不等待垂直同步，每次刷新显示最新一帧，延迟最低 · 垂直同步：每帧都等到刷新才显示，比自动多等最多一个刷新 · 允许撕裂：可能出现撕裂线")
        VSeg {
            objectName: "presentation-display-sync"
            options: [{ id: "0", label: qsTr("允许撕裂") }, { id: "1", label: qsTr("垂直同步") }, { id: "2", label: qsTr("自动") }]
            current: String(veyra.displaySync)
            onPicked: id => veyra.displaySync = Number(id)
        }
    }
    // 可变刷新 (G-SYNC / FreeSync): the switch greys when the monitor cannot
    // do it. The state is read on events only; 刷新显示器状态 in the 信号
    // card asks the driver again.
    VRow {
        label: qsTr("可变刷新")
        hint: veyra.vrrHint
        VSwitch {
            objectName: "presentation-vrr"
            enabled: veyra.vrrState >= 2
            opacity: enabled ? 1 : 0.5
            checked: veyra.variableRefresh
            onToggled: checked => veyra.variableRefresh = checked
        }
    }
    NvidiaVrrProfileRow { backend: presentationRows.profileTools }
    VRow {
        label: qsTr("输出上限")
        enabled: !veyra.presentationOwned
        hint: veyra.presentationStatus
        VSeg {
            objectName: "presentation-output-rate"
            options: [{ id: "0", label: qsTr("关闭", "off") }, { id: "1", label: qsTr("跟随显示器") }, { id: "2", label: qsTr("自定义") }]
            current: String(veyra.outputRateMode)
            onPicked: id => veyra.outputRateMode = Number(id)
        }
    }
    VRow {
        label: qsTr("自定义上限")
        enabled: !veyra.presentationOwned
        visible: veyra.outputRateMode === 2
        RowLayout {
            spacing: 6
            DialogHost.VTextField {
                objectName: "presentation-custom-fps"
                implicitWidth: 90
                text: veyra.outputCustomFps.toFixed(3)
                onEdited: text => { const v = Number(text.replace(",", ".")); if (isFinite(v) && v >= 1 && v <= 1000) veyra.outputCustomFps = v }
            }
            Text { text: "FPS"; color: Theme.t3; font.family: Theme.fontUi; font.pixelSize: 11 }
        }
    }
}
