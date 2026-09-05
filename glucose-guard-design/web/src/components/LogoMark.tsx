import logo from "../assets/logo.png";

export type LoopStatus = "connected" | "idle" | "disconnected";

const STATUS_LABEL: Record<LoopStatus, string> = {
  connected: "Closed loop ready — CGM and pump reading",
  idle: "Waiting for device link",
  disconnected: "Device communication lost",
};

type LogoMarkProps = {
  status: LoopStatus;
  size?: number;
};

export function LogoMark({ status, size = 88 }: LogoMarkProps) {
  return (
    <div
      className={`logo-mark logo-mark--${status}`}
      style={{ width: size, height: size }}
      title={STATUS_LABEL[status]}
    >
      <span className="logo-mark__ring" aria-hidden="true" />
      <img src={logo} alt="Glucose Guard" width={size - 16} height={size - 16} />
    </div>
  );
}
