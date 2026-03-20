export default function AuthLayout({ children }) {
  return (
    <div className="min-h-screen bg-[#0a0a0f] flex items-center justify-center px-4 relative overflow-hidden">

      {/* Decorative background orbs */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        <div
          className="absolute w-72 h-72 rounded-full opacity-20 blur-3xl animate-orb"
          style={{ background: "radial-gradient(circle, #7c6cfc, transparent 70%)", top: "10%", left: "15%" }}
        />
        <div
          className="absolute w-96 h-96 rounded-full opacity-15 blur-3xl animate-orb"
          style={{ background: "radial-gradient(circle, #5eead4, transparent 70%)", bottom: "10%", right: "10%", animationDelay: "4s" }}
        />
        <div
          className="absolute w-48 h-48 rounded-full opacity-10 blur-3xl animate-orb"
          style={{ background: "radial-gradient(circle, #f472b6, transparent 70%)", top: "50%", right: "30%", animationDelay: "8s" }}
        />
      </div>

      <div className="w-full max-w-md relative z-10">
        {/* Logo */}
        <div className="text-center mb-8 animate-fade-up">
          <div className="w-16 h-16 mx-auto rounded-2xl bg-gradient-to-br from-violet-500 to-indigo-600 flex items-center justify-center text-3xl shadow-2xl shadow-violet-500/30 mb-4">
            🔁
          </div>
          <h1 className="text-white text-2xl font-bold tracking-tight">
            Loop<span className="text-transparent bg-clip-text bg-gradient-to-r from-violet-400 to-purple-300">ify</span>
          </h1>
          <p className="text-zinc-500 text-sm mt-1.5">Build habits. Break cycles.</p>
        </div>

        {/* Card */}
        <div className="glass-strong rounded-2xl p-8 shadow-2xl shadow-black/20 animate-fade-up" style={{ animationDelay: '100ms' }}>
          {children}
        </div>
      </div>
    </div>
  );
}