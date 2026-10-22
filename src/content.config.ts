import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';
export const collections = { posts: defineCollection({
  loader: glob({ pattern: '**/*.md', base: './content/posts' }),
  schema: z.object({ title: z.string(), date: z.coerce.date(), summary: z.string(),
    tags: z.array(z.string()).default([]), cover: z.string().optional(), draft: z.boolean().default(false) }) }) };
