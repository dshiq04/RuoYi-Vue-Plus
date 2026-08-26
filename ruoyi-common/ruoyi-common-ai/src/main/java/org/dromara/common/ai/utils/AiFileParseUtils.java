package org.dromara.common.ai.utils;

import lombok.AccessLevel;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.apache.poi.xwpf.extractor.XWPFWordExtractor;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.dromara.common.core.exception.ServiceException;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.List;

/**
 * AI 知识库文件解析工具
 * <p>
 * 支持 PDF (PDFBox) 与 DOCX (Apache POI) 文本提取
 *
 * @author ruoyi
 */
@Slf4j
@NoArgsConstructor(access = AccessLevel.PRIVATE)
public class AiFileParseUtils {

    /**
     * 解析 PDF 文件文本内容
     */
    public static String parsePdf(byte[] bytes) {
        try (PDDocument document = Loader.loadPDF(bytes)) {
            PDFTextStripper stripper = new PDFTextStripper();
            return stripper.getText(document);
        } catch (Exception e) {
            log.error("PDF 文件解析失败", e);
            throw new ServiceException("PDF 文件解析失败: " + e.getMessage());
        }
    }

    /**
     * 解析 DOCX 文件文本内容
     */
    public static String parseDocx(byte[] bytes) {
        try (XWPFDocument document = new XWPFDocument(new ByteArrayInputStream(bytes));
             XWPFWordExtractor extractor = new XWPFWordExtractor(document)) {
            return extractor.getText();
        } catch (Exception e) {
            log.error("DOCX 文件解析失败", e);
            throw new ServiceException("DOCX 文件解析失败: " + e.getMessage());
        }
    }

    /**
     * 文本分片 按字符长度滑动窗口切分
     *
     * @param text    原始文本
     * @param size    每片长度
     * @param overlap 重叠长度
     * @return 分片列表
     */
    public static List<String> split(String text, int size, int overlap) {
        List<String> chunks = new ArrayList<>();
        String cleaned = text.replaceAll("\\s+", " ").trim();
        if (cleaned.isEmpty()) {
            return chunks;
        }
        int step = Math.max(size - overlap, 1);
        int length = cleaned.length();
        for (int start = 0; start < length; start += step) {
            int end = Math.min(start + size, length);
            String chunk = cleaned.substring(start, end).trim();
            if (!chunk.isEmpty()) {
                chunks.add(chunk);
            }
            if (end >= length) {
                break;
            }
        }
        return chunks;
    }

}
