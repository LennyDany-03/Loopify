import { Platform } from "react-native";
import * as SecureStore from "expo-secure-store";
import { create } from "zustand";

const STORAGE_KEY_PREFIX = "loopify_hourly_reminder";
const LEGACY_STORAGE_KEY_PREFIX = "loopify_daily_reminder";

function getWebStorage() {
  if (Platform.OS !== "web" || typeof globalThis.localStorage === "undefined") {
    return null;
  }

  return globalThis.localStorage;
}

async function getStorageItem(key) {
  const webStorage = getWebStorage();

  if (webStorage) {
    return webStorage.getItem(key);
  }

  return SecureStore.getItemAsync(key);
}

async function setStorageItem(key, value) {
  const webStorage = getWebStorage();

  if (webStorage) {
    webStorage.setItem(key, value);
    return;
  }

  await SecureStore.setItemAsync(key, value);
}

function encodeStorageKeySegment(value) {
  return Array.from(String(value ?? ""))
    .map((char) => char.codePointAt(0).toString(16).padStart(4, "0"))
    .join("");
}

function getReminderStorageKey(userId) {
  return `${STORAGE_KEY_PREFIX}.${encodeStorageKeySegment(userId)}`;
}

function getLegacyReminderStorageKey(userId) {
  return `${LEGACY_STORAGE_KEY_PREFIX}.${encodeStorageKeySegment(userId)}`;
}

function getVeryLegacyReminderStorageKey(userId) {
  return `${LEGACY_STORAGE_KEY_PREFIX}:${userId}`;
}

async function readReminderPreferences(userId) {
  if (!userId) {
    return null;
  }

  try {
    const storageKey = getReminderStorageKey(userId);
    let rawValue = await getStorageItem(storageKey);

    if (!rawValue) {
      rawValue = await getStorageItem(getLegacyReminderStorageKey(userId));
    }

    const webStorage = getWebStorage();

    if (!rawValue && webStorage) {
      const veryLegacyKey = getVeryLegacyReminderStorageKey(userId);
      rawValue = webStorage.getItem(veryLegacyKey);

      if (rawValue) {
        webStorage.setItem(storageKey, rawValue);
        webStorage.removeItem(veryLegacyKey);
      }
    }

    if (rawValue) {
      await setStorageItem(storageKey, rawValue);
    }

    return rawValue ? JSON.parse(rawValue) : null;
  } catch {
    return null;
  }
}

async function writeReminderPreferences(userId, preferences) {
  if (!userId) {
    return;
  }

  try {
    await setStorageItem(getReminderStorageKey(userId), JSON.stringify(preferences));
  } catch (error) {
    console.error("Failed to save reminder preferences:", error);
  }
}

const DEFAULT_STATE = {
  isReady: false,
  isUpdating: false,
  userId: null,
  enabled: false,
};

const useReminderStore = create((set, get) => ({
  ...DEFAULT_STATE,

  initialize: async (user) => {
    const nextUserId = user?.id ? String(user.id) : null;

    if (!nextUserId) {
      set({
        ...DEFAULT_STATE,
        isReady: true,
      });
      return;
    }

    if (get().isReady && get().userId === nextUserId) {
      return;
    }

    const storedPreferences = await readReminderPreferences(nextUserId);

    set({
      isReady: true,
      isUpdating: false,
      userId: nextUserId,
      enabled: storedPreferences?.enabled ?? false,
    });
  },

  setEnabled: async (enabled) => {
    const { userId } = get();

    set({ isUpdating: true, enabled });
    await writeReminderPreferences(userId, { enabled });
    set({ isUpdating: false });
  },

  resetSession: () => set({ ...DEFAULT_STATE }),
}));

export default useReminderStore;
