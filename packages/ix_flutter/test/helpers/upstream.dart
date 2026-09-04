/// Traceabilita: názov upstream Playwright testu (`*.ct.ts`) alebo zdroj
/// (`*.scss`, `*.tsx` s riadkom), ktorý test zrkadlí.
class Upstream {
  const Upstream(this.reference);
  final String reference;
}

const upstream = Upstream;
