# Integração online — Hub do Ponto Focal

O site atual no GitHub Pages é uma **demonstração local**: as alterações na Área GECART só existem no navegador do administrador.

## Próximo passo (antes de alterar o site em produção)

1. Criar projeto no Supabase, preferencialmente com conta institucional e aprovação da TI da SEAD.
2. Abrir SQL Editor, executar o conteúdo de `supabase/schema.sql`.
3. Em Authentication > Users, criar/convidar os usuários administradores. Evitar cadastro aberto para a administração.
4. Após obter o UUID de cada usuário autorizado, cadastrar com:
   `insert into public.hub_admins(user_id) values ('UUID-DO-ADMIN');`
5. Guardar a URL do projeto e a chave **publicável** (publishable/anon). A **service_role/secret** jamais deve ser incluída no HTML/GitHub Pages.
6. Ligar o site à API Supabase; substituir operações `localStorage` por consultas à base e autenticação Supabase; validar permissões em navegador anônimo.
7. Depois de testar inclusão, exclusão, consulta e permissões, atualizar o site público e remover o aviso de demonstração.

## Segurança

As políticas de Row Level Security (RLS) incluídas no SQL permitem a qualquer visitante ler categorias e registros, e só aos usuários listados em `hub_admins` escrever. Não armazenar senhas próprias em localStorage. O GitHub Pages é público; tudo que estiver na página, inclusive telefones e endereços, será acessível pela internet. Evite incluir documentos internos/confidenciais. A SEAD deve aprovar hospedagem e tratamento dos dados.

## Importante

Este commit **não ativa** o banco de dados, não altera a aparência do Hub e não compartilha automaticamente novas edições. As alterações online só começarão depois de criar o projeto e ligar a aplicação ao Supabase.
