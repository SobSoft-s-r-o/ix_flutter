/// Traceability: the name of the upstream Playwright test (`*.ct.ts`) or
/// source (`*.scss`, `*.tsx` with a line number) that the test mirrors.
class Upstream {
  const Upstream(this.reference);
  final String reference;
}

const upstream = Upstream;
