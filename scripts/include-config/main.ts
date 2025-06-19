import { parse } from "https://deno.land/std@0.208.0/yaml/mod.ts";
import { ensureDir } from "https://deno.land/std@0.208.0/fs/mod.ts";
import { dirname, join } from "https://deno.land/std@0.208.0/path/mod.ts";

interface DownloadItem {
  path: string;
  url: string;
  extract?: boolean;
  strip_components?: number;
}

async function downloadFile(url: string, filePath: string): Promise<void> {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(
        `Failed to download ${url}: ${response.status} ${response.statusText}`,
      );
    }

    const fileContent = await response.arrayBuffer();
    await ensureDir(dirname(filePath));
    await Deno.writeFile(filePath, new Uint8Array(fileContent));

    console.log(`✓ Installed ${filePath}`);
  } catch (error) {
    console.error(
      `✗ Failed to download ${url} to ${filePath}:`,
      (error as Error).message,
    );
  }
}

async function downloadAndExtractArchive(
  url: string,
  extractPath: string,
  stripComponents?: number,
): Promise<void> {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(
        `Failed to download ${url}: ${response.status} ${response.statusText}`,
      );
    }

    const archiveContent = await response.arrayBuffer();
    const archiveBytes = new Uint8Array(archiveContent);

    // Ensure extraction directory exists
    await ensureDir(extractPath);

    // Determine archive type from URL
    const urlLower = url.toLowerCase();

    if (urlLower.endsWith(".zip")) {
      await extractZip(archiveBytes, extractPath, stripComponents);
    } else if (urlLower.endsWith(".tar.gz") || urlLower.endsWith(".tgz")) {
      await extractTarGz(archiveBytes, extractPath, stripComponents);
    } else if (urlLower.endsWith(".tar")) {
      await extractTar(archiveBytes, extractPath, stripComponents);
    } else {
      throw new Error(
        `Unsupported archive format for ${url}. Supported formats: .zip, .tar, .tar.gz, .tgz`,
      );
    }

    console.log(`✓ Installed ${extractPath}`);
  } catch (error) {
    console.error(
      `✗ Failed to download and extract ${url} to ${extractPath}:`,
      (error as Error).message,
    );
    throw error;
  }
}

async function extractZip(
  archiveBytes: Uint8Array,
  extractPath: string,
  stripComponents?: number,
): Promise<void> {
  const tempFile = await Deno.makeTempFile({ suffix: ".zip" });
  try {
    await Deno.writeFile(tempFile, archiveBytes);

    if (stripComponents && stripComponents > 0) {
      // For zip files with strip components, we need to extract to temp dir first
      // then move files while stripping directory levels
      const tempExtractDir = await Deno.makeTempDir();
      try {
        const extractProcess = new Deno.Command("unzip", {
          args: ["-o", tempFile, "-d", tempExtractDir],
          stdout: "piped",
          stderr: "piped",
        });

        const extractResult = await extractProcess.output();
        if (!extractResult.success) {
          const errorText = new TextDecoder().decode(extractResult.stderr);
          throw new Error(`Failed to extract zip: ${errorText}`);
        }

        // Move files while stripping components
        await stripAndMoveFiles(tempExtractDir, extractPath, stripComponents);
      } finally {
        await Deno.remove(tempExtractDir, { recursive: true });
      }
    } else {
      const process = new Deno.Command("unzip", {
        args: ["-o", tempFile, "-d", extractPath],
        stdout: "piped",
        stderr: "piped",
      });

      const result = await process.output();
      if (!result.success) {
        const errorText = new TextDecoder().decode(result.stderr);
        throw new Error(`Failed to extract zip: ${errorText}`);
      }
    }
  } finally {
    await Deno.remove(tempFile);
  }
}

async function extractTar(
  archiveBytes: Uint8Array,
  extractPath: string,
  stripComponents?: number,
): Promise<void> {
  const tempFile = await Deno.makeTempFile({ suffix: ".tar" });
  try {
    await Deno.writeFile(tempFile, archiveBytes);

    const args = ["-xf", tempFile, "-C", extractPath];
    if (stripComponents && stripComponents > 0) {
      args.push(`--strip-components=${stripComponents}`);
    }

    const process = new Deno.Command("tar", {
      args,
      stdout: "piped",
      stderr: "piped",
    });

    const result = await process.output();
    if (!result.success) {
      const errorText = new TextDecoder().decode(result.stderr);
      throw new Error(`Failed to extract tar: ${errorText}`);
    }
  } finally {
    await Deno.remove(tempFile);
  }
}

async function extractTarGz(
  archiveBytes: Uint8Array,
  extractPath: string,
  stripComponents?: number,
): Promise<void> {
  // Use system tar command for tar.gz files as it handles decompression
  const tempFile = await Deno.makeTempFile({ suffix: ".tar.gz" });
  try {
    await Deno.writeFile(tempFile, archiveBytes);

    const args = ["-xzf", tempFile, "-C", extractPath];
    if (stripComponents && stripComponents > 0) {
      args.push(`--strip-components=${stripComponents}`);
    }

    const process = new Deno.Command("tar", {
      args,
      stdout: "piped",
      stderr: "piped",
    });

    const result = await process.output();
    if (!result.success) {
      const errorText = new TextDecoder().decode(result.stderr);
      throw new Error(`Failed to extract tar.gz: ${errorText}`);
    }
  } finally {
    await Deno.remove(tempFile);
  }
}

async function readYamlConfig(yamlPath: string): Promise<DownloadItem[]> {
  try {
    const yamlContent = await Deno.readTextFile(yamlPath);
    const config = parse(yamlContent) as DownloadItem[];

    if (!Array.isArray(config)) {
      throw new Error("YAML file must contain an array of download items");
    }

    // Validate each item
    for (const item of config) {
      if (!item.path || !item.url) {
        throw new Error("Each item must have both 'path' and 'url' properties");
      }
      if (item.extract !== undefined && typeof item.extract !== "boolean") {
        throw new Error("'extract' property must be a boolean");
      }
      if (
        item.strip_components !== undefined &&
        (typeof item.strip_components !== "number" || item.strip_components < 0)
      ) {
        throw new Error(
          "'strip_components' property must be a non-negative number",
        );
      }
    }

    return config;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) {
      throw new Error(`YAML file not found: ${yamlPath}`);
    }
    throw error;
  }
}

function expandHomePath(filePath: string): string {
  const homeDir = Deno.env.get("HOME");
  if (!homeDir) {
    throw new Error("HOME environment variable is not set");
  }

  // Join the home directory with the relative path
  return join(homeDir, filePath);
}

async function main() {
  const yamlPath = "./config.yaml";

  try {
    const downloadItems = await readYamlConfig(yamlPath);
    for (const item of downloadItems) {
      const fullPath = expandHomePath(item.path);

      if (item.extract) {
        // When extracting, path is treated as a directory
        await downloadAndExtractArchive(
          item.url,
          fullPath,
          item.strip_components,
        );
      } else {
        // Default behavior: download as file
        await downloadFile(item.url, fullPath);
      }
    }
  } catch (error) {
    console.error("Error:", (error as Error).message);
    Deno.exit(1);
  }
}

async function stripAndMoveFiles(
  sourceDir: string,
  targetDir: string,
  stripComponents: number,
): Promise<void> {
  for await (const entry of Deno.readDir(sourceDir)) {
    const sourcePath = join(sourceDir, entry.name);

    if (entry.isFile) {
      // For files, strip the specified number of directory components
      const pathParts = entry.name.split("/");
      if (pathParts.length > stripComponents) {
        const strippedPath = pathParts.slice(stripComponents).join("/");
        const targetPath = join(targetDir, strippedPath);
        await ensureDir(dirname(targetPath));
        await Deno.copyFile(sourcePath, targetPath);
      }
    } else if (entry.isDirectory) {
      // Recursively process directories
      await stripAndMoveDirectory(sourcePath, targetDir, stripComponents, [
        entry.name,
      ]);
    }
  }
}

async function stripAndMoveDirectory(
  sourceDir: string,
  targetBaseDir: string,
  stripComponents: number,
  currentPath: string[],
): Promise<void> {
  for await (const entry of Deno.readDir(sourceDir)) {
    const sourcePath = join(sourceDir, entry.name);
    const fullPath = [...currentPath, entry.name];

    if (entry.isFile) {
      // For files, check if we should strip this many components
      if (fullPath.length > stripComponents) {
        const strippedPath = fullPath.slice(stripComponents).join("/");
        const targetPath = join(targetBaseDir, strippedPath);
        await ensureDir(dirname(targetPath));
        await Deno.copyFile(sourcePath, targetPath);
      }
    } else if (entry.isDirectory) {
      // Recursively process subdirectories
      await stripAndMoveDirectory(
        sourcePath,
        targetBaseDir,
        stripComponents,
        fullPath,
      );
    }
  }
}

await main();
