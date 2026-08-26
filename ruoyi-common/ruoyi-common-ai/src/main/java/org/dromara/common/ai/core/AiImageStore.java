package org.dromara.common.ai.core;

import cn.hutool.core.util.IdUtil;
import org.springframework.ai.content.Media;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.util.MimeType;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * AI 对话上传图片临时存储
 * <p>
 * 图片在发送消息时取出构造多模态消息 默认 30 分钟过期
 *
 * @author ruoyi
 */
public class AiImageStore {

    /**
     * 过期时间(毫秒)
     */
    private static final long EXPIRE_MILLIS = 30 * 60 * 1000L;

    private final Map<String, CachedImage> store = new ConcurrentHashMap<>();

    /**
     * 缓存图片 返回图片ID
     */
    public String put(byte[] data, String mimeType, String fileName) {
        cleanExpired();
        String id = IdUtil.fastSimpleUUID();
        store.put(id, new CachedImage(data, mimeType, fileName, System.currentTimeMillis()));
        return id;
    }

    /**
     * 取出图片并移除缓存 构造多模态 Media 列表
     */
    public List<Media> take(List<String> imageIds) {
        List<Media> medias = new ArrayList<>();
        if (imageIds == null || imageIds.isEmpty()) {
            return medias;
        }
        for (String id : imageIds) {
            CachedImage image = store.remove(id);
            if (image != null) {
                medias.add(new Media(MimeType.valueOf(image.mimeType()), new ByteArrayResource(image.data())));
            }
        }
        return medias;
    }

    private void cleanExpired() {
        long now = System.currentTimeMillis();
        Iterator<Map.Entry<String, CachedImage>> it = store.entrySet().iterator();
        while (it.hasNext()) {
            if (now - it.next().getValue().putTime() > EXPIRE_MILLIS) {
                it.remove();
            }
        }
    }

    private record CachedImage(byte[] data, String mimeType, String fileName, long putTime) {
    }

}
