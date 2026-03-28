// Shell.jsx — page content wrapper
// Provides consistent max-width, padding, and spacing
// for every dashboard page. Wrap page content with this.
//
// Usage:
//   <Shell title="My Loops" subtitle="3 active loops">
//     {children}
//   </Shell>

export default function Shell({ title, subtitle, action, children }) {
  return (
    <div className="max-w-5xl mx-auto w-full">

      {/* Page header — only renders if title is passed */}
      {title && (
        <div className="flex items-start justify-between mb-6">
          <div>
            <h1 className="text-white text-2xl font-bold">{title}</h1>
            {subtitle && (
              <p className="text-zinc-500 text-sm mt-0.5">{subtitle}</p>
            )}
          </div>
          {/* Optional action button/element on the right */}
          {action && <div>{action}</div>}
        </div>
      )}

      {/* Page body */}
      <div className="space-y-6">{children}</div>

    </div>
  );
}