import{a as E,r as e}from"./index.37e74b2a.js";var l,d,f=E;d=f.createRoot,l=f.hydrateRoot;const n=({value:t,name:r,hydrate:a=!0})=>{if(!t)return null;const o=a?"astro-slot":"astro-static-slot";return e.createElement(o,{name:r,suppressHydrationWarning:!0,dangerouslySetInnerHTML:{__html:t}})};n.shouldComponentUpdate=()=>!1;function x(t){for(const r in t)if(r.startsWith("__reactContainer"))return r}const h=t=>(r,a,{default:o,...y},{client:m})=>{if(!t.hasAttribute("ssr"))return;const s={identifierPrefix:t.getAttribute("prefix")};for(const[u,p]of Object.entries(y))a[u]=e.createElement(n,{value:p,name:u});const i=e.createElement(r,a,o!=null?e.createElement(n,{value:o}):o),c=x(t);return c&&delete t[c],m==="only"?e.startTransition(()=>{d(t,s).render(i)}):e.startTransition(()=>{l(t,i,s)})};export{h as default};
