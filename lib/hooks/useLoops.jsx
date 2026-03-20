"use client";

import { useEffect } from "react";
import useLoopStore from "../store/useLoopStore";

export function useLoops() {
  const {
    loops,
    isLoading,
    error,
    fetchLoops,
    createLoop,
    updateLoop,
    deleteLoop,
    clearError,
  } = useLoopStore();

  // Auto-fetch on mount
  useEffect(() => {
    if (!loops.length) fetchLoops();
  }, []);

  return {
    loops,
    isLoading,
    error,
    clearError,
    refetch:    fetchLoops,
    createLoop,
    updateLoop,
    deleteLoop,
  };
}

export function useLoop(id) {
  const { loops, isLoading, fetchLoops } = useLoopStore();

  useEffect(() => {
    if (!loops.length) fetchLoops();
  }, []);

  const loop = loops.find((l) => l.id === id) ?? null;
  return { loop, isLoading };
}