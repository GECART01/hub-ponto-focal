-- Hub do Ponto Focal — Supabase
-- Execute no SQL Editor de um projeto Supabase.
-- Os registros são públicos para leitura; edição exige conta administradora autorizada.
create extension if not exists pgcrypto;

create table if not exists public.hub_admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.hub_categories (
  id text primary key,
  name text not null,
  sort_order integer not null default 100
);
create table if not exists public.hub_resources (
  id uuid primary key default gen_random_uuid(),
  category_id text not null references public.hub_categories(id),
  title text not null,
  address text not null,
  note text not null default '',
  sort_order integer not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.hub_admins enable row level security;
alter table public.hub_categories enable row level security;
alter table public.hub_resources enable row level security;

-- Consulta anônima de cards e categorias.
create policy "Hub categorias leitura publica" on public.hub_categories
  for select to anon, authenticated using (true);
create policy "Hub cards leitura publica" on public.hub_resources
  for select to anon, authenticated using (true);

-- Cada usuario autenticado pode verificar apenas sua própria autorização.
create policy "Hub verificar proprio admin" on public.hub_admins
  for select to authenticated using (user_id = (select auth.uid()));

create policy "Hub admin cria categorias" on public.hub_categories
  for insert to authenticated with check (exists (select 1 from public.hub_admins where user_id = (select auth.uid())));
create policy "Hub admin edita categorias" on public.hub_categories
  for update to authenticated using (exists (select 1 from public.hub_admins where user_id = (select auth.uid()))) with check (exists (select 1 from public.hub_admins where user_id = (select auth.uid())));
create policy "Hub admin exclui categorias" on public.hub_categories
  for delete to authenticated using (exists (select 1 from public.hub_admins where user_id = (select auth.uid())));
create policy "Hub admin cria cards" on public.hub_resources
  for insert to authenticated with check (exists (select 1 from public.hub_admins where user_id = (select auth.uid())));
create policy "Hub admin edita cards" on public.hub_resources
  for update to authenticated using (exists (select 1 from public.hub_admins where user_id = (select auth.uid()))) with check (exists (select 1 from public.hub_admins where user_id = (select auth.uid())));
create policy "Hub admin exclui cards" on public.hub_resources
  for delete to authenticated using (exists (select 1 from public.hub_admins where user_id = (select auth.uid())));

insert into public.hub_categories(id,name,sort_order) values
 ('link','Links',1),('modelo','Links modelo',2),('email','E-mails',3),('sei','Processos SEI',4),('telefone','Telefones',5)
on conflict (id) do nothing;

insert into public.hub_resources(category_id,title,address,note,sort_order)
select x.category_id,x.title,x.address,x.note,x.sort_order
from (values
 ('link','Endereço Portal Expresso','https://www.go.gov.br/','',1),
 ('link','Acesso ao Portal Goiás (Expresso Aplicações)','https://aplicacoes.expresso.go.gov.br','',2),
 ('link','Expresso Admin Homolog','https://apihomolog.goiasdigital.go.gov.br/admin/home','',3),
 ('link','Expresso Web Homolog','https://wwwhomolog.go.gov.br/','',4),
 ('link','Acesso ao Portal Goiás (Expresso Aplicações) Homolog','https://aplicacoeshomolog.expresso.go.gov.br/','',5),
 ('link','Sharepoint da carta de serviços','https://goiasgovbr.sharepoint.com/sites/cartadeservicos','',6),
 ('email','E-mail da GECART','cartadeservicos.sead@goias.gov.br','',7),
 ('email','Criação de usuários no SAG','atendimento.sti@goias.gov.br','',8),
 ('link','SAG - alteração de link ou resolução de problemas','https://atendimento.sistemas.go.gov.br/','',9),
 ('sei','Processo SEI para indicação de Pontos Focais na Rede','Processo nº 202400005029996','',10),
 ('modelo','Endereço padrão para vincular link de serviço com ID','https://www.go.gov.br/servicos/servico-id/xxxx','Este link serve apenas para copiar e usar de modelo. Substitua o final ''xxxx'' pelo ID do serviço para vincular em outros portais sem quebrar o link se o nome mudar.',11),
 ('telefone','Gabriela - GECART','62 - 99603-8311','',12),
 ('telefone','Gustavo - GECART','62 - 99802-6202','',13),
 ('telefone','Henrique - GECART','62 - 98133-7847','',14)
) as x(category_id,title,address,note,sort_order)
where not exists(select 1 from public.hub_resources);
