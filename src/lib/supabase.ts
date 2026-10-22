import { createClient } from '@supabase/supabase-js';
export const sb = createClient(import.meta.env.PUBLIC_SUPABASE_URL, import.meta.env.PUBLIC_SUPABASE_ANON_KEY);
