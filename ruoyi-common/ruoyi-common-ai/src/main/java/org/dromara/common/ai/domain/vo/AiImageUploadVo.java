package org.dromara.common.ai.domain.vo;

import lombok.Data;

/**
 * AI 图片上传结果视图对象
 *
 * @author ruoyi
 */
@Data
public class AiImageUploadVo {

    /**
     * 图片ID 发送消息时携带
     */
    private String imageId;

    /**
     * 文件名
     */
    private String fileName;

    /**
     * 媒体类型
     */
    private String mimeType;

}
