// Připojení k databázi Supabase.
// Obě hodnoty najdeš v Supabase: Project Settings → API (Project URL a anon public key).
// Anon klíč je určený pro prohlížeč a smí být veřejný – data chrání pravidla v databázi (jen trenéři ze seznamu).
window.SERIZENI_CONFIG = {
  supabaseUrl: '',      // např. 'https://abcdefgh.supabase.co'
  supabaseAnonKey: ''   // dlouhý řetězec začínající 'eyJ…'
};
