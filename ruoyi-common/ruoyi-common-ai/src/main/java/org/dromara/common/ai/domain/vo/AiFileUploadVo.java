package org.dromara.common.ai.domain.vo;

import lombok.Data;

/**
 * AI 文件上传结果视图对象
 *
 * @author ruoyi
 */
@Data
public class AiFileUploadVo {

    /**
     * 文件名
     */
    private String fileName;

    /**
     * 解析后写入向量库的分片数量
     */
    private Integer chunkCount;

}
