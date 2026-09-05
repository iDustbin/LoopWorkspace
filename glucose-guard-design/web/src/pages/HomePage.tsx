import { Link } from "react-router-dom";
import { LogoMark } from "../components/LogoMark";

export function HomePage() {
  return (
    <section className="hero">
      <LogoMark status="connected" size={112} />
      <h1>Glucose Guard</h1>
      <p className="lede">
        A closed-loop companion brand on top of Loop. This web app is the
        design shell — not a place to read live glucose or pump values yet.
      </p>
      <div className="actions">
        <Link className="button" to="/today">
          Open Today
        </Link>
        <Link className="button button--ghost" to="/profile">
          Profile
        </Link>
      </div>
      <aside className="disclaimer">
        Glucose Guard is a support brand around open-source Loop. It is not a
        medical device and does not replace clinical advice. Step 1 does not
        display CGM, insulin, or Nightscout data.
      </aside>
    </section>
  );
}
