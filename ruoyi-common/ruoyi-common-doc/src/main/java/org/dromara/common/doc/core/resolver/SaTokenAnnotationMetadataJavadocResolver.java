package org.dromara.common.doc.core.resolver;

import cn.hutool.core.convert.Convert;
import cn.hutool.core.util.ClassLoaderUtil;
import io.swagger.v3.oas.models.Operation;
import lombok.extern.slf4j.Slf4j;
import org.dromara.common.doc.core.model.SaTokenSecurityMetadata;
import org.springframework.web.method.HandlerMethod;

import java.lang.annotation.Annotation;
import java.util.List;
import java.util.Map;
import java.util.function.Supplier;

/**
 * 基于JavaDoc的SaToken权限解析器
 *
 * @author echo
 * @author 秋辞未寒
 */
@SuppressWarnings("unchecked")
@Slf4j
public class SaTokenAnnotationMetadataJavadocResolver extends AbstractMetadataJavadocResolver<SaTokenSecurityMetadata> {

    /**
     * 默认元数据提供者，每次解析都会创建一个新的元数据对象
     */
    public static final Supplier<SaTokenSecurityMetadata> DEFAULT_METADATA_PROVIDER = SaTokenSecurityMetadata::new;

    private static final String BASE_CLASS_NAME = "org.springframework.security.access.prepost";
    private static final String PRE_AUTHORIZE_CLASS_NAME = BASE_CLASS_NAME + ".PreAuthorize";
    private static final String SECURED_CLASS_NAME = "org.springframework.security.access.annotation.Secured";
    private static final String PERMIT_ALL_CLASS_NAME = "jakarta.annotation.security.PermitAll";
    private static final String ROLES_ALLOWED_CLASS_NAME = "jakarta.annotation.security.RolesAllowed";

    private static final Class<? extends Annotation> PRE_AUTHORIZE_CLASS;
    private static final Class<? extends Annotation> SECURED_CLASS;
    private static final Class<? extends Annotation> PERMIT_ALL_CLASS;
    private static final Class<? extends Annotation> ROLES_ALLOWED_CLASS;


    static {
        // 通过类加载器去加载注解类Class实例
        PRE_AUTHORIZE_CLASS = (Class<? extends Annotation>) ClassLoaderUtil.loadClass(PRE_AUTHORIZE_CLASS_NAME, false);
        SECURED_CLASS = (Class<? extends Annotation>) ClassLoaderUtil.loadClass(SECURED_CLASS_NAME, false);
        PERMIT_ALL_CLASS = (Class<? extends Annotation>) ClassLoaderUtil.loadClass(PERMIT_ALL_CLASS_NAME, false);
        ROLES_ALLOWED_CLASS = (Class<? extends Annotation>) ClassLoaderUtil.loadClass(ROLES_ALLOWED_CLASS_NAME, false);
        if (log.isDebugEnabled()) {
            log.debug("SecurityAnnotationJavadocResolver init success, load annotation class: {}", List.of(PRE_AUTHORIZE_CLASS, SECURED_CLASS, PERMIT_ALL_CLASS, ROLES_ALLOWED_CLASS));
        }
    }

    public SaTokenAnnotationMetadataJavadocResolver() {
        this(DEFAULT_METADATA_PROVIDER);
    }

    public SaTokenAnnotationMetadataJavadocResolver(Supplier<SaTokenSecurityMetadata> metadataProvider) {
        super(metadataProvider);
    }

    public SaTokenAnnotationMetadataJavadocResolver(int order) {
        this(DEFAULT_METADATA_PROVIDER,order);
    }

    public SaTokenAnnotationMetadataJavadocResolver(Supplier<SaTokenSecurityMetadata> metadataProvider, int order) {
        super(metadataProvider,order);
    }

    @Override
    public boolean supports(HandlerMethod handlerMethod) {
        return hasAnnotation(handlerMethod, PRE_AUTHORIZE_CLASS) || hasAnnotation(handlerMethod, SECURED_CLASS) || hasAnnotation(handlerMethod, PERMIT_ALL_CLASS) || hasAnnotation(handlerMethod, ROLES_ALLOWED_CLASS);
    }

    @Override
    public String resolve(HandlerMethod handlerMethod, Operation operation, SaTokenSecurityMetadata metadata) {
        // 检查是否忽略校验
        if(hasAnnotation(handlerMethod, PERMIT_ALL_CLASS_NAME)){
            metadata.setIgnore(true);
            return metadata.toMarkdownString();
        }

        // 解析权限校验(@PreAuthorize)
        resolvePreAuthorize(handlerMethod, metadata);

        // 解析角色校验(@Secured / @RolesAllowed)
        resolveRoleCheck(handlerMethod, metadata);
        return metadata.toMarkdownString();
    }

    /**
     * 解析权限校验(@PreAuthorize)
     */
    private void resolvePreAuthorize(HandlerMethod handlerMethod, SaTokenSecurityMetadata metadata) {
        // 解析获取方法上的注解权限信息
        if (hasMethodAnnotation(handlerMethod, PRE_AUTHORIZE_CLASS_NAME)) {
            Map<String, Object> annotationValueMap = getMethodAnnotationValueMap(handlerMethod, PRE_AUTHORIZE_CLASS);
            resolvePreAuthorizeAnnotation(metadata, annotationValueMap);
        }
        // 解析获取类上的注解权限信息
        if (hasClassAnnotation(handlerMethod, PRE_AUTHORIZE_CLASS_NAME)) {
            Map<String, Object> annotationValueMap = getClassAnnotationValueMap(handlerMethod, PRE_AUTHORIZE_CLASS);
            resolvePreAuthorizeAnnotation(metadata, annotationValueMap);
        }
    }

    /**
     * 解析@PreAuthorize注解
     */
    private void resolvePreAuthorizeAnnotation(SaTokenSecurityMetadata metadata, Map<String, Object> annotationValueMap) {
        try {
            Object value = annotationValueMap.get("value");
            if (value != null) {
                String spelExpr = value.toString();
                metadata.addPermission(new String[]{spelExpr}, "AND", "", new String[]{});
            }
        } catch (Exception ignore) {
            // 忽略解析错误
        }
    }

    /**
     * 解析角色校验(@Secured / @RolesAllowed)
     */
    private void resolveRoleCheck(HandlerMethod handlerMethod, SaTokenSecurityMetadata metadata) {
        // 解析@Secured
        if (hasMethodAnnotation(handlerMethod, SECURED_CLASS_NAME)) {
            Map<String, Object> annotationValueMap = getMethodAnnotationValueMap(handlerMethod, SECURED_CLASS);
            resolveRoleAnnotation(metadata, annotationValueMap);
        }
        if (hasClassAnnotation(handlerMethod, SECURED_CLASS_NAME)) {
            Map<String, Object> annotationValueMap = getClassAnnotationValueMap(handlerMethod, SECURED_CLASS);
            resolveRoleAnnotation(metadata, annotationValueMap);
        }
        // 解析@RolesAllowed
        if (hasMethodAnnotation(handlerMethod, ROLES_ALLOWED_CLASS_NAME)) {
            Map<String, Object> annotationValueMap = getMethodAnnotationValueMap(handlerMethod, ROLES_ALLOWED_CLASS);
            resolveRoleAnnotation(metadata, annotationValueMap);
        }
        if (hasClassAnnotation(handlerMethod, ROLES_ALLOWED_CLASS_NAME)) {
            Map<String, Object> annotationValueMap = getClassAnnotationValueMap(handlerMethod, ROLES_ALLOWED_CLASS);
            resolveRoleAnnotation(metadata, annotationValueMap);
        }
    }

    /**
     * 解析角色注解
     */
    private void resolveRoleAnnotation(SaTokenSecurityMetadata metadata, Map<String, Object> annotationValueMap) {
        try {
            Object value = annotationValueMap.get("value");
            String[] values = Convert.toStrArray(value);
            metadata.addRole(values, "AND", "");
        } catch (Exception ignore) {
            // 忽略解析错误
        }
    }

}
