import rss from '@astrojs/rss'; import { getCollection } from 'astro:content';
export async function GET(c){const posts=(await getCollection('posts')).filter(p=>!p.data.draft).sort((a,b)=>+b.data.date-+a.data.date);
return rss({title:'Mi Blog',description:'Tecnología e IA agéntica',site:c.site+import.meta.env.BASE_URL,
items:posts.map(p=>({title:p.data.title,pubDate:p.data.date,description:p.data.summary,link:`posts/${p.id}/`}))})}
