type PlaceholderPageProps = {
  title: string;
  summary: string;
};

export function PlaceholderPage({ title, summary }: PlaceholderPageProps) {
  return (
    <section className="panel">
      <p className="eyebrow">Coming later</p>
      <h1>{title}</h1>
      <p>{summary}</p>
      <p className="muted">
        No diabetic values are loaded in this step. Charts, Withings, Rex.fit,
        and clinician access stay out of the first release.
      </p>
    </section>
  );
}
