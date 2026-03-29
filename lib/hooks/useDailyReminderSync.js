import { useEffect } from "react";
import { AppState } from "react-native";
import useAuthStore from "../store/useAuthStore";
import useLoopStore from "../store/useLoopStore";
import useReminderStore from "../store/useReminderStore";
import { syncHourlyLoopReminderAsync } from "../notifications/dailyReminder";

export default function useDailyReminderSync({ enabled = true } = {}) {
  const user = useAuthStore((state) => state.user);
  const loops = useLoopStore((state) => state.loops);
  const todayCheckins = useLoopStore((state) => state.todayCheckins);
  const initializeReminder = useReminderStore((state) => state.initialize);
  const isReminderReady = useReminderStore((state) => state.isReady);
  const isReminderEnabled = useReminderStore((state) => state.enabled);

  useEffect(() => {
    if (!enabled) {
      return;
    }

    void initializeReminder(user);
  }, [enabled, initializeReminder, user]);

  useEffect(() => {
    if (!enabled || !isReminderReady) {
      return;
    }

    void syncHourlyLoopReminderAsync({
      enabled: isReminderEnabled,
      loops,
      todayCheckins,
    });
  }, [enabled, isReminderEnabled, isReminderReady, loops, todayCheckins]);

  useEffect(() => {
    if (!enabled || !isReminderReady) {
      return undefined;
    }

    const subscription = AppState.addEventListener("change", (nextAppState) => {
      if (nextAppState !== "active") {
        return;
      }

      void syncHourlyLoopReminderAsync({
        enabled: useReminderStore.getState().enabled,
        loops: useLoopStore.getState().loops,
        todayCheckins: useLoopStore.getState().todayCheckins,
      });
    });

    return () => {
      subscription.remove();
    };
  }, [enabled, isReminderReady]);
}
