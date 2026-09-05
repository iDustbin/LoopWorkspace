import { NavLink, Outlet } from "react-router-dom";
import { LogoMark, type LoopStatus } from "./LogoMark";

type AppShellProps = {
  theme: "light" | "dark";
  status: LoopStatus;
  onToggleTheme: () => void;
};

const NAV = [
  { to: "/today", label: "Today" },
  { to: "/learning", label: "Learning" },
  { to: "/healthway", label: "Healthway" },
  { to: "/add", label: "+", end: true },
  { to: "/profile", label: "Profile" },
];

export function AppShell({ theme, status, onToggleTheme }: AppShellProps) {
  return (
    <div className="shell">
      <header className="topbar">
        <NavLink to="/" className="brand">
          <LogoMark status={status} size={44} />
          <div>
            <p className="brand__name">Glucose Guard</p>
            <p className="brand__status">
              {status === "connected" ? "Loop connected" : "Preview shell"}
            </p>
          </div>
        </NavLink>
        <button type="button" className="ghost" onClick={onToggleTheme}>
          {theme === "dark" ? "Light" : "Dark"}
        </button>
      </header>
      <main className="content">
        <Outlet />
      </main>
      <nav className="tabbar" aria-label="Primary">
        {NAV.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.end}
            className={({ isActive }) =>
              item.label === "+"
                ? `tab tab--add${isActive ? " is-active" : ""}`
                : `tab${isActive ? " is-active" : ""}`
            }
          >
            {item.label}
          </NavLink>
        ))}
      </nav>
    </div>
  );
}
