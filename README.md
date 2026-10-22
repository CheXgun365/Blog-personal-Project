# Blog en GitHub Pages + Supabase

## Limitaciones reales (leer primero)
- **Correos sin dominio**: Brevo/Buttondown envían desde su dominio o desde tu Gmail verificado; sin SPF/DKIM propios muchos correos caen en spam. Alternativa gratis: **Buttondown** (plan gratis hasta 100 suscriptores, hospeda la suscripción y la baja por ti) o un dominio gratuito en Cloudflare/is-a.dev si luego lo quieres.
- Mejor para ti: **Buttondown** al inicio (confirmación y baja ya incluidas, cero código). Brevo si superas 100 suscriptores.
- Los secretos nunca van al frontend; solo la `anon key` (protegida por RLS).
- Supabase gratis pausa el proyecto tras 7 días sin actividad.

## 1. Supabase
1. supabase.com → New project. 2. SQL Editor → pega `supabase/schema.sql` → Run.
3. Project Settings → API: copia `Project URL` y `anon public key`.
4. Authentication → URL Configuration: Site URL `https://CheXgun365.github.io/NOMBRE-REPO/`; Redirect URLs: esa misma + `http://localhost:4321/**`.

## 2. Google login
1. console.cloud.google.com → proyecto nuevo → APIs & Services → OAuth consent screen (External) → publica.
2. Credentials → Create → OAuth client ID → Web. Authorized redirect URI: `https://TU-REF.supabase.co/auth/v1/callback`.
3. Copia Client ID y Secret → Supabase → Authentication → Providers → Google → pega y activa.

## 3. GitHub Pages
1. Edita `base` en `astro.config.mjs` con el nombre real del repo.
2. Repo → Settings → Secrets and variables → Actions: crea `PUBLIC_SUPABASE_URL` y `PUBLIC_SUPABASE_ANON_KEY`.
3. Settings → Pages → Source: **GitHub Actions**. Haz push a `main`.

## 4. Newsletter (Buttondown, recomendado)
Crea cuenta, copia tu formulario de suscripción y úsalo como acción del form, o deja la tabla `subscribers` y exporta cada tanto. Brevo: Contacts → crear lista; Senders → verifica tu Gmail como remitente.

## 5. Publicar
`./scripts/new-post.sh "Título" "Resumen" "ia,agentes" < cuerpo.md` — crea el .md y hace push; el Action despliega. Un agente local solo ejecuta ese comando.

## 6. Límites gratis
Supabase: 50k usuarios activos/mes, 500 MB BD. GitHub Pages: 100 GB/mes de ancho de banda. Brevo: 300 correos/día. Si crece: cachear, subir de plan o mover a Cloudflare Pages.

## 7. Pruebas
Login Google · comentar · responder · editar · borrar propio · borrar ajeno (admin: `update profiles set is_admin=true where id=...`) · reportar · suscribirse · RSS en `/rss.xml`.
