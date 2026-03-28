"use client";

import { useEffect } from "react";
import useLoopStore from "../store/useLoopStore";

export function useCheckin() {
  const { todayCheckins, fetchTodayCheckins, checkinLoop } = useLoopStore();

  // Load today's checkins on mount
  useEffect(() => {
    if (!Object.keys(todayCheckins).length) fetchTodayCheckins();
  }, []);

  function isCheckedToday(loopId) {
    return !!todayCheckins[loopId];
  }

  async function logCheckin(loopId, value = null, note = null) {
    if (isCheckedToday(loopId)) {
      return { success: false, error: "Already checked in today." };
    }
    return checkinLoop(loopId, value, note);
  }

  return {
    todayCheckins,
    isCheckedToday,
    logCheckin,
    refetch: fetchTodayCheckins,
  };
}