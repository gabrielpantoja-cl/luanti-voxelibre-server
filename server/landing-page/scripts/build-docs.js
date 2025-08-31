#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Script para convertir archivos Markdown de /docs a JSON para el frontend
 * Genera: assets/data/docs.json con toda la documentación
 */

// Configuración
const DOCS_DIR = path.join(__dirname, '../../../docs');
const OUTPUT_DIR = path.join(__dirname, '../assets/data');
const OUTPUT_FILE = path.join(OUTPUT_DIR, 'docs.json');

// Mapeo de archivos a metadatos
const DOCS_CONFIG = {
  '1-guia-del-servidor.md': {
    id: 'servidor',
    title: '🌱 Guía del Servidor',
    description: 'Todo sobre cómo jugar en Wetlands',
    icon: '🎮',
    audience: 'jugadores',
    order: 1
  },
  '2-guia-de-administracion.md': {
    id: 'admin',
    title: '🛠️ Administración',
    description: 'Manual para administradores',
    icon: '👨‍💼',
    audience: 'admins',
    order: 2
  },
  '3-guia-de-desarrollo.md': {
    id: 'desarrollo',
    title: '💻 Desarrollo',
    description: 'Cómo contribuir al proyecto',
    icon: '🔧',
    audience: 'developers',
    order: 3
  },
  '4-guia-de-despliegue.md': {
    id: 'despliegue',
    title: '🚀 Despliegue',
    description: 'Deploy y CI/CD del servidor',
    icon: '⚙️',
    audience: 'devops',
    order: 4
  }
};

/**
 * Parser básico de Markdown para extraer estructura
 */
function parseMarkdown(content) {
  const lines = content.split('\n');
  const sections = [];
  let currentSection = null;
  let currentContent = [];

  for (const line of lines) {
    // Detectar encabezados
    if (line.startsWith('#')) {
      // Guardar sección anterior si existe
      if (currentSection) {
        currentSection.content = currentContent.join('\n').trim();
        sections.push(currentSection);
      }

      // Nueva sección
      const level = (line.match(/^#+/) || [''])[0].length;
      const title = line.replace(/^#+\s*/, '');
      
      currentSection = {
        level,
        title,
        id: title.toLowerCase()
          .replace(/[^\w\s-]/g, '') // Remover caracteres especiales
          .replace(/\s+/g, '-')     // Espacios a guiones
          .replace(/^-+|-+$/g, ''), // Limpiar guiones al inicio/final
        content: ''
      };
      currentContent = [];
    } else {
      // Agregar contenido a la sección actual
      currentContent.push(line);
    }
  }

  // Guardar última sección
  if (currentSection) {
    currentSection.content = currentContent.join('\n').trim();
    sections.push(currentSection);
  }

  return sections;
}

/**
 * Función principal
 */
async function buildDocs() {
  try {
    console.log('🔨 Construyendo documentación...');
    
    // Crear directorio de salida si no existe
    if (!fs.existsSync(OUTPUT_DIR)) {
      fs.mkdirSync(OUTPUT_DIR, { recursive: true });
    }

    // Leer todos los archivos de documentación
    const docs = [];
    const files = fs.readdirSync(DOCS_DIR);

    for (const filename of files) {
      if (!filename.endsWith('.md') || !DOCS_CONFIG[filename]) {
        continue;
      }

      console.log(`📖 Procesando: ${filename}`);
      
      const filePath = path.join(DOCS_DIR, filename);
      const content = fs.readFileSync(filePath, 'utf8');
      const config = DOCS_CONFIG[filename];
      
      // Parser el contenido Markdown
      const sections = parseMarkdown(content);
      
      // Crear objeto de documentación
      const doc = {
        ...config,
        filename,
        sections,
        lastModified: fs.statSync(filePath).mtime.toISOString(),
        wordCount: content.split(/\s+/).length
      };

      docs.push(doc);
    }

    // Ordenar por orden configurado
    docs.sort((a, b) => a.order - b.order);

    // Crear índice de navegación
    const navigation = docs.map(doc => ({
      id: doc.id,
      title: doc.title,
      icon: doc.icon,
      description: doc.description,
      audience: doc.audience,
      sectionsCount: doc.sections.length,
      wordCount: doc.wordCount
    }));

    // Objeto final
    const output = {
      meta: {
        generated: new Date().toISOString(),
        version: '1.0.0',
        totalDocs: docs.length,
        totalSections: docs.reduce((sum, doc) => sum + doc.sections.length, 0)
      },
      navigation,
      docs: docs.reduce((acc, doc) => {
        acc[doc.id] = doc;
        return acc;
      }, {})
    };

    // Escribir archivo JSON
    fs.writeFileSync(OUTPUT_FILE, JSON.stringify(output, null, 2), 'utf8');
    
    console.log('✅ Documentación construida exitosamente!');
    console.log(`📊 Estadísticas:`);
    console.log(`   • ${docs.length} documentos procesados`);
    console.log(`   • ${output.meta.totalSections} secciones totales`);
    console.log(`   • Archivo generado: ${OUTPUT_FILE}`);
    
  } catch (error) {
    console.error('❌ Error construyendo documentación:', error);
    process.exit(1);
  }
}

// Ejecutar si es llamado directamente
if (require.main === module) {
  buildDocs();
}

module.exports = { buildDocs };