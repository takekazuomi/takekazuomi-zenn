#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// 設定
const DIAGRAMS_DIR = path.join(__dirname, '..', 'articles', 'draft', 'diagrams');
const IMAGES_DIR = path.join(__dirname, '..', 'images');
const TMP_DIR = path.join(__dirname, '..', '.tmp');

// ディレクトリ作成
if (!fs.existsSync(IMAGES_DIR)) {
  fs.mkdirSync(IMAGES_DIR, { recursive: true });
}
if (!fs.existsSync(TMP_DIR)) {
  fs.mkdirSync(TMP_DIR, { recursive: true });
}

/**
 * 外部ファイルのアスキーアートからPNG生成
 */
function generatePNGFromDiagramFile(diagramFilePath) {
  const diagramName = path.basename(diagramFilePath, '.txt');
  console.log(`Processing: ${diagramName}`);

  // アスキーアートを読み込み
  const asciiArt = fs.readFileSync(diagramFilePath, 'utf-8');

  // svgbobでSVG生成（一時ファイル）
  const tmpSvg = path.join(TMP_DIR, `${diagramName}.svg`);
  const outputPng = path.join(IMAGES_DIR, `${diagramName}.png`);

  try {
    // svgbob_cliコマンド実行（フルパス使用、日本語対応等幅フォント指定）
    const svgbobCmd = process.env.HOME ? `${process.env.HOME}/.cargo/bin/svgbob_cli` : 'svgbob_cli';
    execSync(`${svgbobCmd} --font-family "UDEV Gothic" ${diagramFilePath} -o ${tmpSvg}`, {
      stdio: 'pipe'
    });

    // resvgでSVG→PNG変換
    const resvgCmd = process.env.HOME ? `${process.env.HOME}/.cargo/bin/resvg` : 'resvg';
    execSync(`${resvgCmd} ${tmpSvg} ${outputPng}`, {
      stdio: 'pipe'
    });

    console.log(`  ✓ Generated: ${outputPng}`);

    // 一時SVGファイル削除
    fs.unlinkSync(tmpSvg);

    return true;
  } catch (error) {
    console.error(`  ✗ Error generating PNG for ${diagramName}:`, error.message);
    console.error(`  Make sure svgbob_cli and resvg are installed: make install-tools`);
    return false;
  }
}

/**
 * メイン処理
 */
function main() {
  console.log(`Generating PNGs from diagram files...\n`);

  // diagrams ディレクトリが存在しない場合は終了
  if (!fs.existsSync(DIAGRAMS_DIR)) {
    console.log(`Diagrams directory not found: ${DIAGRAMS_DIR}`);
    console.log(`No diagrams to process.`);
    return;
  }

  // diagrams ディレクトリ内の .txt ファイルを処理
  const diagramFiles = fs.readdirSync(DIAGRAMS_DIR)
    .filter(file => file.endsWith('.txt'))
    .map(file => path.join(DIAGRAMS_DIR, file));

  if (diagramFiles.length === 0) {
    console.log(`No diagram files found in: ${DIAGRAMS_DIR}`);
    return;
  }

  let successCount = 0;
  diagramFiles.forEach(file => {
    if (generatePNGFromDiagramFile(file)) {
      successCount++;
    }
  });

  console.log(`\nTotal: ${successCount} PNG(s) generated`);
}

main();
