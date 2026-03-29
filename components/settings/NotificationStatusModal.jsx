import React from "react";
import { Modal, Pressable, Text, TouchableOpacity, View } from "react-native";
import { Feather } from "@expo/vector-icons";
import useAppTheme from "../../lib/hooks/useAppTheme";
import { withOpacity } from "../../lib/theme";

const TONE_CONFIG = {
  accent: {
    colorKey: "accent",
    icon: "bell",
  },
  success: {
    colorKey: "success",
    icon: "check",
  },
  warning: {
    colorKey: "warning",
    icon: "alert-triangle",
  },
  danger: {
    colorKey: "danger",
    icon: "bell-off",
  },
};

export default function NotificationStatusModal({
  isVisible,
  onClose,
  title,
  message,
  tone = "accent",
  icon,
  actionLabel = "OK",
}) {
  const { theme, isDark } = useAppTheme();
  const toneConfig = TONE_CONFIG[tone] || TONE_CONFIG.accent;
  const accentColor = theme[toneConfig.colorKey] || theme.accent;
  const iconName = icon || toneConfig.icon;
  const buttonTextColor =
    tone === "accent" ? theme.tabActiveIcon : isDark ? "#050508" : "#FFFFFF";

  return (
    <Modal
      animationType="fade"
      transparent={true}
      visible={isVisible}
      onRequestClose={onClose}
    >
      <Pressable
        className="flex-1 items-center justify-center px-6"
        style={{ backgroundColor: theme.overlay }}
        onPress={onClose}
      >
        <View
          className="w-full rounded-[32px] p-8 items-center border"
          style={{ backgroundColor: theme.surface, borderColor: theme.borderStrong }}
          onStartShouldSetResponder={() => true}
        >
          <View
            className="w-20 h-20 rounded-full items-center justify-center mb-6 border"
            style={{
              backgroundColor: withOpacity(accentColor, isDark ? 0.12 : 0.1),
              borderColor: withOpacity(accentColor, isDark ? 0.22 : 0.18),
            }}
          >
            <Feather name={iconName} size={32} color={accentColor} />
          </View>

          <Text className="text-2xl font-bold mb-3 text-center tracking-tight" style={{ color: theme.text }}>
            {title}
          </Text>

          <Text
            className="text-[15px] text-center leading-6 mb-8 px-2 font-medium"
            style={{ color: theme.textMuted }}
          >
            {message}
          </Text>

          <TouchableOpacity
            activeOpacity={0.85}
            onPress={onClose}
            className="w-full py-4 rounded-[20px] items-center justify-center"
            style={{ backgroundColor: accentColor }}
          >
            <Text className="text-base font-extrabold uppercase tracking-wide" style={{ color: buttonTextColor }}>
              {actionLabel}
            </Text>
          </TouchableOpacity>
        </View>
      </Pressable>
    </Modal>
  );
}
