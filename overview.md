# Overview do Projeto Code-Graph-RAG

## Descrição Geral

O **Code-Graph-RAG** é um sistema avançado de Retrieval-Augmented Generation (RAG) que analisa codebases multi-linguagem usando Tree-sitter para parsing, constrói grafos de conhecimento abrangentes e permite consultas em linguagem natural sobre a estrutura e relacionamentos do código, além de capacidades de edição.

## 1. Linguagens Suportadas

### Localização da Configuração
O suporte às linguagens está definido em **`codebase_rag/language_config.py`** através da estrutura `LANGUAGE_CONFIGS`.

### Linguagens Implementadas

| Linguagem   | Extensões de Arquivo | Nós AST Suportados | Status |
|-------------|---------------------|-------------------|--------|
| **Python**     | `.py` | `function_definition`, `class_definition`, `call` | ✅ Completo |
| **JavaScript**  | `.js`, `.jsx` | `function_declaration`, `arrow_function`, `method_definition`, `class_declaration`, `call_expression` | ✅ Completo |
| **TypeScript**  | `.ts`, `.tsx` | `function_declaration`, `arrow_function`, `method_definition`, `class_declaration`, `call_expression` | ✅ Completo |
| **Rust**        | `.rs` | `function_item`, `struct_item`, `enum_item`, `impl_item`, `call_expression` | ✅ Completo |
| **Go**          | `.go` | `function_declaration`, `method_declaration`, `type_declaration`, `call_expression` | ✅ Completo |
| **Java**        | `.java` | `method_declaration`, `constructor_declaration`, `class_declaration`, `interface_declaration`, `enum_declaration`, `method_invocation` | ✅ Completo |
| **Scala**       | `.scala`, `.sc` | `function_definition`, `class_definition`, `object_definition`, `trait_definition`, `call_expression`, `generic_function` | ✅ Completo |
| **C++**         | `.cpp`, `.h`, `.hpp`, `.cc`, `.cxx`, `.hxx`, `.hh` | `function_definition`, `class_specifier`, `struct_specifier`, `union_specifier`, `enum_specifier`, `call_expression` | ✅ Completo |

### Configuração de Linguagem
Cada linguagem é definida através da classe `LanguageConfig` com os seguintes campos:
```python
@dataclass
class LanguageConfig:
    name: str                           # Nome da linguagem
    file_extensions: list[str]          # Extensões de arquivos
    function_node_types: list[str]      # Tipos de nós para funções
    class_node_types: list[str]         # Tipos de nós para classes/structs
    module_node_types: list[str]        # Tipos de nós para módulos
    call_node_types: list[str]          # Tipos de nós para chamadas
    name_field: str = "name"            # Campo do nome no AST
    body_field: str = "body"            # Campo do corpo no AST
    package_indicators: list[str]       # Indicadores de pacotes (ex: __init__.py)
```

## 2. Dependências de LLM

### Provedores Suportados

O projeto suporta múltiplos provedores de LLM através da biblioteca **`pydantic-ai`**:

#### 1. **Google Gemini** (Padrão)
- **Modelos**:
  - Orquestrador: `gemini-2.5-pro`
  - Geração Cypher: `gemini-2.5-flash-lite-preview-06-17`
- **Provedores**: Google AI Studio (GLA) ou Vertex AI
- **Configuração**: `GEMINI_API_KEY` ou `GCP_PROJECT_ID`

#### 2. **OpenAI**
- **Modelos**:
  - Orquestrador: `gpt-4o-mini`
  - Geração Cypher: `gpt-4o-mini`
- **Configuração**: `OPENAI_API_KEY`

#### 3. **Modelos Locais** (Ollama)
- **Modelos**:
  - Orquestrador: `llama3`
  - Geração Cypher: `llama3`
- **Endpoint**: `http://localhost:11434/v1`
- **Configuração**: Ollama instalado localmente

### Bibliotecas de IA
- **`pydantic-ai`**: Framework principal para agentes de IA
- **`tree-sitter`**: Parsing de código multi-linguagem
- **Dependências específicas**:
  ```toml
  "pydantic-ai-slim[google,openai,vertexai]>=0.2.18"
  "tree-sitter==0.25.0"
  "tree-sitter-python>=0.23.6"
  # ... outras linguagens
  ```

## 3. Uso do LLM no Projeto

### Localização do Código LLM
O uso de LLM está centralizado em **`codebase_rag/services/llm.py`**.

### Componentes Principais

#### 3.1 **CypherGenerator**
- **Função**: Converte perguntas em linguagem natural para consultas Cypher
- **Prompt**: `CYPHER_SYSTEM_PROMPT` (em `prompts.py`)
- **Uso**: Tradução de queries para o banco de grafos Memgraph

#### 3.2 **RAG Orchestrator**
- **Função**: Agente principal que coordena todas as operações
- **Prompt**: `RAG_ORCHESTRATOR_SYSTEM_PROMPT`
- **Ferramentas**: 8 ferramentas especializadas
- **Capacidades**:
  - Consulta do grafo de conhecimento
  - Leitura e edição de arquivos
  - Execução de comandos shell
  - Análise de documentos
  - Recuperação de código

### Fluxo de Uso do LLM

1. **Entrada do Usuário** → Interface de chat interativa
2. **Processamento** → RAG Orchestrator analisa a solicitação
3. **Geração de Cypher** → CypherGenerator traduz queries para o banco
4. **Consulta do Grafo** → Memgraph retorna dados estruturados
5. **Processamento** → LLM sintetiza resposta final
6. **Saída** → Resposta em linguagem natural com referências

### Detecção Automática de Provider
```python
def detect_provider_from_model(model_name: str) -> Literal["gemini", "openai", "local"]:
    if model_name.startswith("gemini-"):
        return "gemini"
    elif model_name.startswith("gpt-") or model_name.startswith("o1-"):
        return "openai"
    else:
        return "local"
```

## 4. Aspectos Arquiteturais

### 4.1 Arquitetura Geral

```
┌─────────────────────────────────────────────────────────────────┐
│                        CODE-GRAPH-RAG                          │
├─────────────────────────────────────────────────────────────────┤
│  CLI Interface (main.py)                                       │
│  ├── Interactive Chat                                          │
│  ├── Optimization Mode                                         │
│  └── Export/Import                                             │
├─────────────────────────────────────────────────────────────────┤
│  RAG Orchestrator (llm.py)                                    │
│  ├── Tool Coordination                                         │
│  ├── LLM Integration                                           │
│  └── Context Management                                        │
├─────────────────────────────────────────────────────────────────┤
│  Tools Layer                                                   │
│  ├── Codebase Query    ├── Code Retrieval                     │
│  ├── File Operations   ├── Shell Commands                     │
│  ├── Directory Listing ├── Document Analysis                  │
│  └── File Editing                                             │
├─────────────────────────────────────────────────────────────────┤
│  Graph Layer                                                   │
│  ├── Graph Updater (Tree-sitter Parsing)                     │
│  ├── Language Configs                                         │
│  └── Memgraph Ingestor                                        │
├─────────────────────────────────────────────────────────────────┤
│  Storage Layer                                                 │
│  ├── Memgraph Database (Grafos)                               │
│  ├── File System (Código Fonte)                               │
│  └── AST Cache                                                │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Componentes Principais

#### **Graph Updater** (`graph_updater.py`)
- **Responsabilidade**: Parser multi-linguagem usando Tree-sitter
- **Processo**:
  1. **Pass 1**: Identificação de estrutura (packages/folders)
  2. **Pass 2**: Processamento de arquivos e cache de ASTs
  3. **Pass 3**: Análise de chamadas de função
- **Cache**: AST cache para performance
- **Filtros**: Ignora diretórios como `.git`, `node_modules`, `__pycache__`

#### **Memgraph Ingestor** (`services/graph_service.py`)
- **Responsabilidade**: Interface com banco de dados de grafos
- **Features**:
  - Batching para performance
  - Constraints automáticos
  - Export/Import de grafos
  - Context manager para conexões
- **Configuração**: Host: `localhost:7687`

#### **Parser Loader** (`parser_loader.py`)
- **Responsabilidade**: Carregamento dinâmico de parsers Tree-sitter
- **Fallback**: Suporte a submódulos Git para novas linguagens
- **Auto-detecção**: Compila queries automaticamente para cada linguagem

### 4.3 Schema do Grafo de Conhecimento

#### **Tipos de Nós**
```cypher
// Estrutura Hierárquica
Project {name: string}
Package {qualified_name: string, name: string, path: string}
Folder {path: string, name: string}
File {path: string, name: string, extension: string}

// Elementos de Código
Module {qualified_name: string, name: string, path: string}
Class {qualified_name: string, name: string, decorators: list[string]}
Function {qualified_name: string, name: string, decorators: list[string]}
Method {qualified_name: string, name: string, decorators: list[string]}

// Dependências
ExternalPackage {name: string, version_spec: string}
```

#### **Relacionamentos**
```cypher
// Contenção
(Project|Package|Folder)-[:CONTAINS_*]->(Package|Folder|File|Module)

// Definições
(Module)-[:DEFINES]->(Class|Function)
(Class)-[:DEFINES_METHOD]->(Method)

// Dependências
(Project)-[:DEPENDS_ON_EXTERNAL]->(ExternalPackage)

// Chamadas
(Function|Method)-[:CALLS]->(Function|Method)
```

### 4.4 Ferramentas (Tools)

#### **Consulta e Recuperação**
1. **`query_codebase_knowledge_graph`**: Consulta Cypher em linguagem natural
2. **`get_code_snippet`**: Recuperação de código específico
3. **`read_file_content`**: Leitura de arquivos

#### **Operações de Arquivo**
4. **`create_new_file`**: Criação de novos arquivos
5. **`replace_code_surgically`**: Edição cirúrgica de código (AST-based)
6. **`list_directory_contents`**: Listagem de diretórios

#### **Execução e Análise**
7. **`execute_shell_command`**: Execução de comandos shell
8. **`analyze_document`**: Análise de documentos (PDFs, etc.)

### 4.5 Modos de Operação

#### **1. Parse & Ingest**
```bash
python -m codebase_rag.main start --repo-path /path/to/repo --update-graph --clean
```
- Parsing completo do codebase
- Construção do grafo de conhecimento
- Suporte a múltiplos repositórios

#### **2. Interactive Query**
```bash
python -m codebase_rag.main start --repo-path /path/to/repo
```
- Chat interativo com o codebase
- Perguntas em linguagem natural
- Edição de código assistida por IA

#### **3. Export & Analyze**
```bash
python -m codebase_rag.main export -o graph.json
```
- Export programático do grafo
- Análise externa de dados
- Integração com outras ferramentas

#### **4. AI Optimization**
```bash
python -m codebase_rag.main optimize python --repo-path /path/to/repo
```
- Otimização assistida por IA
- Aplicação de melhores práticas
- Workflow de aprovação interativo

### 4.6 Configuração e Deploy

#### **Dependências de Sistema**
- **Python 3.12+**
- **Docker & Docker Compose** (Memgraph)
- **uv** package manager

#### **Configuração via Environment**
```bash
# LLM Configuration
GEMINI_API_KEY=your_api_key
OPENAI_API_KEY=your_api_key
LOCAL_MODEL_ENDPOINT=http://localhost:11434/v1

# Database Configuration
MEMGRAPH_HOST=localhost
MEMGRAPH_PORT=7687

# Application Configuration
TARGET_REPO_PATH=.
SHELL_COMMAND_TIMEOUT=30
```

#### **Docker Compose**
```yaml
services:
  memgraph:
    image: memgraph/memgraph-mage
    ports: ["7687:7687", "7444:7444"]
  lab:
    image: memgraph/lab
    ports: ["3000:3000"]
```

### 4.7 Performance e Escalabilidade

#### **Otimizações Implementadas**
- **Batching**: Inserções em lote no Memgraph
- **AST Cache**: Cache de ASTs para reprocessamento
- **Índices**: Constraints únicos por tipo de nó
- **Lazy Loading**: Carregamento sob demanda de parsers

#### **Monitoramento**
- **Logs estruturados** com Loguru
- **Métricas de parsing** por linguagem
- **Estatísticas de grafo** (nós/relacionamentos)

### 4.8 Extensibilidade

#### **Adição de Novas Linguagens**
```bash
python -m codebase_rag.tools.language add-grammar <language-name>
```
- Suporte automático a Tree-sitter grammars
- Detecção automática de tipos de nós
- Compilação automática de bindings Python

#### **Personalização de Prompts**
- Prompts centralizados em `prompts.py`
- Personalização por provider (local vs cloud)
- Schema de grafo como fonte única da verdade

### 4.9 Segurança e Confiabilidade

#### **Validação de Entrada**
- **Pydantic Settings** para configuração tipada
- **Validação de APIs keys** por provider
- **Sandbox de arquivos** (limitado ao projeto)

#### **Error Handling**
- **Context managers** para recursos
- **Flush automático** em caso de erro
- **Rollback** de operações parciais

#### **Isolamento**
- **Containers Docker** para Memgraph
- **Ambientes virtuais** Python
- **Timeouts** configuráveis para operações

## Conclusão

O Code-Graph-RAG representa uma arquitetura robusta e escalável para análise de código multi-linguagem, combinando técnicas modernas de parsing (Tree-sitter), armazenamento em grafos (Memgraph) e IA generativa (LLMs) para criar uma experiência de desenvolvimento assistida por IA altamente eficaz.

A arquitetura modular permite fácil extensão para novas linguagens e provedores de LLM, enquanto mantém alta performance através de otimizações como batching, caching e processamento paralelo.
