"use client";

import { useState } from "react";
import Button from "@/components/ui/Button";

const CATEGORIES = ["General","Fitness","Study","Finance","Health","Mindfulness","Work","Creative","Social"];
const FREQUENCIES = ["daily", "weekly", "custom"];
const TARGET_TYPES = ["boolean", "number", "duration"];
const DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const COLORS = ["#7c6cfc","#5eead4","#fb923c","#f472b6","#4ade80","#facc15","#60a5fa","#f87171"];

const DEFAULTS = {
  name: "", icon: "🔁", category: "General",
  color: "#7c6cfc", frequency: "daily", custom_days: [],
  target_type: "boolean", target_value: "", target_unit: "",
};

export default function LoopForm({ initialData, onSubmit, onCancel }) {
  const [form, setForm] = useState({ ...DEFAULTS, ...initialData });
  const [isLoading, setIsLoading] = useState(false);

  function set(field, value) {
    setForm((prev) => ({ ...prev, [field]: value }));
  }

  function toggleDay(day) {
    setForm((prev) => ({
      ...prev,
      custom_days: prev.custom_days.includes(day)
        ? prev.custom_days.filter((d) => d !== day)
        : [...prev.custom_days, day],
    }));
  }

  async function handleSubmit(e) {
    e.preventDefault();
    setIsLoading(true);
    const payload = {
      ...form,
      target_value: form.target_value ? parseFloat(form.target_value) : null,
      target_unit:  form.target_unit  || null,
    };
    await onSubmit(payload);
    setIsLoading(false);
  }

  const isEdit = !!initialData;

  return (
    <form onSubmit={handleSubmit} className="space-y-5">

      {/* Name + Icon row */}
      <div className="flex gap-3">
        <div className="flex-1">
          <label className="text-zinc-400 text-xs uppercase tracking-wide mb-1.5 block">
            Loop Name <span className="text-red-400">*</span>
          </label>
          <input
            type="text"
            value={form.name}
            onChange={(e) => set("name", e.target.value)}
            required
            placeholder="Morning Run"
            maxLength={80}
            className="w-full bg-[#1a1a24] border border-white/[0.08] text-white text-sm rounded-lg px-4 py-2.5 outline-none focus:border-violet-500 transition-colors placeholder:text-zinc-600"
          />
        </div>
        <div className="w-20">
          <label className="text-zinc-400 text-xs uppercase tracking-wide mb-1.5 block">Icon</label>
          <input
            type="text"
            value={form.icon}
            onChange={(e) => set("icon", e.target.value)}
            placeholder="🔁"
            className="w-full bg-[#1a1a24] border border-white/[0.08] text-white text-xl text-center rounded-lg px-2 py-2.5 outline-none focus:border-violet-500 transition-colors"
          />
        </div>
      </div>

      {/* Category + Frequency */}
      <div className="grid grid-cols-2 gap-3">
        <div>
          <label className="text-zinc-400 text-xs uppercase tracking-wide mb-1.5 block">Category</label>
          <select
            value={form.category}
            onChange={(e) => set("category", e.target.value)}
            className="w-full bg-[#1a1a24] border border-white/[0.08] text-white text-sm rounded-lg px-3 py-2.5 outline-none focus:border-violet-500 transition-colors"
          >
            {CATEGORIES.map((c) => <option key={c} value={c}>{c}</option>)}
          </select>
        </div>
        <div>
          <label className="text-zinc-400 text-xs uppercase tracking-wide mb-1.5 block">Frequency</label>
          <select
            value={form.frequency}
            onChange={(e) => set("frequency", e.target.value)}
            className="w-full bg-[#1a1a24] border border-white/[0.08] text-white text-sm rounded-lg px-3 py-2.5 outline-none focus:border-violet-500 transition-colors"
          >
            {FREQUENCIES.map((f) => <option key={f} value={f}>{f}</option>)}
          </select>
        </div>
      </div>

      {/* Custom days picker — only if frequency = custom */}
      {form.frequency === "custom" && (
        <div>
          <label className="text-zinc-400 text-xs uppercase tracking-wide mb-2 block">Active Days</label>
          <div className="flex gap-2">
            {DAYS.map((day) => (
              <button
                key={day}
                type="button"
                onClick={() => toggleDay(day)}
                className={`text-xs px-2.5 py-1.5 rounded-lg border transition-colors ${
                  form.custom_days.includes(day)
                    ? "bg-violet-600 border-violet-600 text-white"
                    : "border-white/[0.08] text-zinc-500 hover:border-violet-500 hover:text-white"
                }`}
              >
                {day}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Target type */}
      <div>
        <label className="text-zinc-400 text-xs uppercase tracking-wide mb-2 block">Target Type</label>
        <div className="flex gap-2">
          {TARGET_TYPES.map((t) => (
            <button
              key={t}
              type="button"
              onClick={() => set("target_type", t)}
              className={`text-xs px-3 py-1.5 rounded-lg border transition-colors capitalize ${
                form.target_type === t
                  ? "bg-violet-600 border-violet-600 text-white"
                  : "border-white/[0.08] text-zinc-500 hover:border-violet-500 hover:text-white"
              }`}
            >
              {t === "boolean" ? "✅ Yes/No" : t === "number" ? "🔢 Number" : "⏱ Duration"}
            </button>
          ))}
        </div>
      </div>

      {/* Target value + unit — only if not boolean */}
      {form.target_type !== "boolean" && (
        <div className="grid grid-cols-2 gap-3">
          <div>
            <label className="text-zinc-400 text-xs uppercase tracking-wide mb-1.5 block">Target Value</label>
            <input
              type="number"
              value={form.target_value}
              onChange={(e) => set("target_value", e.target.value)}
              placeholder="5"
              min="0"
              className="w-full bg-[#1a1a24] border border-white/[0.08] text-white text-sm rounded-lg px-4 py-2.5 outline-none focus:border-violet-500 transition-colors placeholder:text-zinc-600"
            />
          </div>
          <div>
            <label className="text-zinc-400 text-xs uppercase tracking-wide mb-1.5 block">Unit</label>
            <input
              type="text"
              value={form.target_unit}
              onChange={(e) => set("target_unit", e.target.value)}
              placeholder="km, mins, pages"
              className="w-full bg-[#1a1a24] border border-white/[0.08] text-white text-sm rounded-lg px-4 py-2.5 outline-none focus:border-violet-500 transition-colors placeholder:text-zinc-600"
            />
          </div>
        </div>
      )}

      {/* Color picker */}
      <div>
        <label className="text-zinc-400 text-xs uppercase tracking-wide mb-2 block">Color</label>
        <div className="flex items-center gap-2 flex-wrap">
          {COLORS.map((c) => (
            <button
              key={c}
              type="button"
              onClick={() => set("color", c)}
              className="w-7 h-7 rounded-full border-2 transition-all"
              style={{
                background: c,
                borderColor: form.color === c ? "#fff" : "transparent",
                transform: form.color === c ? "scale(1.2)" : "scale(1)",
              }}
            />
          ))}
        </div>
      </div>

      {/* Actions */}
      <div className="flex gap-3 pt-2">
        <Button type="submit" disabled={isLoading} className="flex-1">
          {isLoading ? "Saving..." : isEdit ? "Save Changes" : "Create Loop"}
        </Button>
        <Button type="button" variant="ghost" onClick={onCancel} className="flex-1">
          Cancel
        </Button>
      </div>

    </form>
  );
}