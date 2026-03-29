import { Platform } from "react-native";
import { requireOptionalNativeModule } from "expo-modules-core";
import { isLoopCompletedToday } from "../utils/loopMetrics";

export const HOURLY_LOOP_REMINDER_CHANNEL_ID = "hourly-loop-reminders";
export const HOURLY_LOOP_REMINDER_ID = "loopify-hourly-loop-reminder";
export const HOURLY_LOOP_REMINDER_KIND = "hourly-loop-reminder";
export const HOURLY_LOOP_REMINDER_TEST_KIND = "hourly-loop-reminder-test";
export const HOURLY_LOOP_REMINDER_INTERVAL_SECONDS = 60 * 60;

const LEGACY_DAILY_LOOP_REMINDER_ID = "loopify-daily-loop-reminder";
const LEGACY_DAILY_LOOP_REMINDER_KIND = "daily-loop-reminder";

export const MOTIVATION_MESSAGES = [
  "Your next small win can change the whole day.",
  "One more loop gets you closer to 100 percent.",
  "Progress loves consistency. Keep showing up.",
  "You are building proof that you can trust yourself.",
  "Small actions stack into real momentum.",
  "A quick loop right now is better than a perfect plan later.",
  "The streak gets stronger every time you return.",
  "Keep moving. Your future self is paying attention.",
  "You are closer to done than you were an hour ago.",
  "A focused minute now can unlock the rest of your day.",
  "Discipline grows when you finish what you started.",
  "Show up for one loop and let momentum do the rest.",
  "You do not need perfect energy to make solid progress.",
  "Today still counts. Push your analysis to 100 percent.",
  "A small finish now will feel amazing later.",
];

export const DAILY_LOOP_REMINDER_CHANNEL_ID = HOURLY_LOOP_REMINDER_CHANNEL_ID;
export const DAILY_LOOP_REMINDER_ID = HOURLY_LOOP_REMINDER_ID;
export const DAILY_LOOP_REMINDER_KIND = HOURLY_LOOP_REMINDER_KIND;

let hasConfiguredHandler = false;
let hasConfiguredChannel = false;
let hasWarnedUnavailable = false;
let cachedNotificationsModule;

function getNotificationsModule() {
  if (Platform.OS === "web") {
    return null;
  }

  if (cachedNotificationsModule !== undefined) {
    return cachedNotificationsModule;
  }

  const hasPushTokenManager = !!requireOptionalNativeModule("ExpoPushTokenManager");
  const hasNotificationScheduler = !!requireOptionalNativeModule("ExpoNotificationScheduler");

  if (!hasPushTokenManager || !hasNotificationScheduler) {
    cachedNotificationsModule = null;

    if (!hasWarnedUnavailable) {
      console.warn(
        "expo-notifications native module is unavailable. Rebuild the app/dev client before using Loopify reminders."
      );
      hasWarnedUnavailable = true;
    }

    return cachedNotificationsModule;
  }

  try {
    cachedNotificationsModule = require("expo-notifications");
  } catch (error) {
    cachedNotificationsModule = null;

    if (!hasWarnedUnavailable) {
      console.warn("Failed to load expo-notifications:", error?.message || error);
      hasWarnedUnavailable = true;
    }
  }

  return cachedNotificationsModule;
}

function pickMotivationMessage() {
  const index = Math.floor(Math.random() * MOTIVATION_MESSAGES.length);
  return MOTIVATION_MESSAGES[index] || MOTIVATION_MESSAGES[0];
}

function buildReminderContent({ completionRate, completedLoops, remainingLoops, totalLoops }) {
  const progressLine =
    completionRate <= 0
      ? "Your analysis is still at 0 percent today."
      : `Your analysis is at ${completionRate} percent today.`;

  const loopCopy =
    remainingLoops === 1
      ? "1 loop is still open."
      : `${remainingLoops} of ${totalLoops} loops are still open.`;

  return {
    title: completionRate === 0 ? "Start your next Loopify win" : "Keep pushing toward 100%",
    body: `${progressLine} ${loopCopy} ${pickMotivationMessage()}`,
    data: {
      kind: HOURLY_LOOP_REMINDER_KIND,
      completedLoops,
      remainingLoops,
      completionRate,
      totalLoops,
    },
  };
}

function buildTestReminderContent() {
  return {
    title: "Loopify reminder test",
    body: `This is your hourly reminder preview. ${pickMotivationMessage()}`,
    data: {
      kind: HOURLY_LOOP_REMINDER_TEST_KIND,
      isTest: true,
    },
  };
}

function configureNotificationHandler() {
  const Notifications = getNotificationsModule();

  if (!Notifications || hasConfiguredHandler) {
    return;
  }

  Notifications.setNotificationHandler({
    handleNotification: async () => ({
      shouldShowBanner: true,
      shouldShowList: true,
      shouldPlaySound: true,
      shouldSetBadge: false,
    }),
  });

  hasConfiguredHandler = true;
}

export function getHourlyLoopReminderStatus({ loops = [], todayCheckins = {} } = {}) {
  const totalLoops = Array.isArray(loops) ? loops.length : 0;
  const completedLoops = Array.isArray(loops)
    ? loops.filter((loop) => isLoopCompletedToday(loop, todayCheckins)).length
    : 0;
  const remainingLoops = Math.max(totalLoops - completedLoops, 0);
  const completionRate = totalLoops > 0 ? Math.round((completedLoops / totalLoops) * 100) : 0;

  return {
    totalLoops,
    completedLoops,
    remainingLoops,
    completionRate,
    shouldNotify: totalLoops > 0 && remainingLoops > 0 && completionRate < 100,
  };
}

export const getLoopReminderStatus = getHourlyLoopReminderStatus;

export async function configureReminderNotificationsAsync() {
  const Notifications = getNotificationsModule();

  if (!Notifications) {
    return false;
  }

  configureNotificationHandler();

  if (Platform.OS === "android" && !hasConfiguredChannel) {
    await Notifications.setNotificationChannelAsync(HOURLY_LOOP_REMINDER_CHANNEL_ID, {
      name: "Hourly loop reminders",
      description: "Hourly motivation for unfinished loops.",
      importance: Notifications.AndroidImportance.HIGH,
      vibrationPattern: [0, 250, 250, 250],
      lightColor: "#4F8EF7",
      showBadge: false,
    });

    hasConfiguredChannel = true;
  }

  return true;
}

function isLoopReminderRequest(request) {
  const identifier = request?.identifier;
  const kind = request?.content?.data?.kind;

  return (
    identifier === HOURLY_LOOP_REMINDER_ID ||
    identifier === LEGACY_DAILY_LOOP_REMINDER_ID ||
    kind === HOURLY_LOOP_REMINDER_KIND ||
    kind === LEGACY_DAILY_LOOP_REMINDER_KIND
  );
}

export async function cancelHourlyLoopReminderAsync() {
  const Notifications = getNotificationsModule();

  if (!Notifications) {
    return;
  }

  const scheduled = await Notifications.getAllScheduledNotificationsAsync();
  const reminderNotifications = scheduled.filter(isLoopReminderRequest);

  await Promise.allSettled(
    reminderNotifications.map((request) =>
      Notifications.cancelScheduledNotificationAsync(request.identifier)
    )
  );
}

export const cancelDailyLoopReminderAsync = cancelHourlyLoopReminderAsync;

export async function requestReminderPermissionsAsync() {
  const Notifications = getNotificationsModule();

  if (!Notifications) {
    return { granted: false, canAskAgain: false, status: "module-unavailable" };
  }

  await configureReminderNotificationsAsync();

  const currentPermissions = await Notifications.getPermissionsAsync();
  if (currentPermissions.granted) {
    return currentPermissions;
  }

  return Notifications.requestPermissionsAsync();
}

export async function syncHourlyLoopReminderAsync({
  enabled,
  loops = [],
  todayCheckins = {},
} = {}) {
  const Notifications = getNotificationsModule();

  if (!Notifications) {
    return { scheduled: false, reason: "module-unavailable" };
  }

  await configureReminderNotificationsAsync();

  if (!enabled) {
    await cancelHourlyLoopReminderAsync();
    return { scheduled: false, reason: "disabled" };
  }

  const permissions = await Notifications.getPermissionsAsync();
  if (!permissions.granted) {
    await cancelHourlyLoopReminderAsync();
    return { scheduled: false, reason: "permission-denied" };
  }

  const reminderStatus = getHourlyLoopReminderStatus({ loops, todayCheckins });

  if (!reminderStatus.shouldNotify) {
    await cancelHourlyLoopReminderAsync();
    return { scheduled: false, reason: "not-needed", status: reminderStatus };
  }

  const content = buildReminderContent(reminderStatus);

  await cancelHourlyLoopReminderAsync();

  const identifier = await Notifications.scheduleNotificationAsync({
    identifier: HOURLY_LOOP_REMINDER_ID,
    content: {
      ...content,
      sound: true,
      priority: Notifications.AndroidNotificationPriority.HIGH,
    },
    trigger: {
      type: Notifications.SchedulableTriggerInputTypes.TIME_INTERVAL,
      seconds: HOURLY_LOOP_REMINDER_INTERVAL_SECONDS,
      repeats: true,
      channelId: HOURLY_LOOP_REMINDER_CHANNEL_ID,
    },
  });

  return {
    scheduled: true,
    identifier,
    intervalSeconds: HOURLY_LOOP_REMINDER_INTERVAL_SECONDS,
    status: reminderStatus,
  };
}

export const syncDailyLoopReminderAsync = syncHourlyLoopReminderAsync;

export async function enableHourlyLoopReminderAsync({
  loops = [],
  todayCheckins = {},
} = {}) {
  const permissions = await requestReminderPermissionsAsync();

  if (!permissions.granted) {
    await cancelHourlyLoopReminderAsync();
    return {
      success: false,
      reason: permissions.status === "module-unavailable" ? "module-unavailable" : "permission-denied",
    };
  }

  const result = await syncHourlyLoopReminderAsync({
    enabled: true,
    loops,
    todayCheckins,
  });

  return {
    success: true,
    ...result,
  };
}

export const enableDailyLoopReminderAsync = enableHourlyLoopReminderAsync;

export async function sendTestHourlyLoopReminderAsync() {
  const Notifications = getNotificationsModule();

  if (!Notifications) {
    return { success: false, reason: "module-unavailable" };
  }

  const permissions = await requestReminderPermissionsAsync();

  if (!permissions.granted) {
    return {
      success: false,
      reason: permissions.status === "module-unavailable" ? "module-unavailable" : "permission-denied",
    };
  }

  const identifier = await Notifications.scheduleNotificationAsync({
    content: {
      ...buildTestReminderContent(),
      sound: true,
      priority: Notifications.AndroidNotificationPriority.HIGH,
    },
    trigger:
      Platform.OS === "android"
        ? { channelId: HOURLY_LOOP_REMINDER_CHANNEL_ID }
        : null,
  });

  return {
    success: true,
    identifier,
  };
}
