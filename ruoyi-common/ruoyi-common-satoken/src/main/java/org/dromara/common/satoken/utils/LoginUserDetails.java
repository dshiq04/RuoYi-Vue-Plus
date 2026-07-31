package org.dromara.common.satoken.utils;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Getter;
import org.dromara.common.core.domain.model.LoginUser;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.HashSet;
import java.util.Set;

@Getter
public class LoginUserDetails implements UserDetails {

    private final LoginUser loginUser;
    private final Collection<? extends GrantedAuthority> authorities;

    public LoginUserDetails(LoginUser loginUser) {
        this.loginUser = loginUser;
        this.authorities = buildAuthorities(loginUser);
    }

    private Collection<? extends GrantedAuthority> buildAuthorities(LoginUser loginUser) {
        Set<GrantedAuthority> authorities = new HashSet<>();
        if (loginUser.getMenuPermission() != null) {
            loginUser.getMenuPermission().forEach(perm ->
                authorities.add(new SimpleGrantedAuthority(perm))
            );
        }
        if (loginUser.getRolePermission() != null) {
            loginUser.getRolePermission().forEach(role ->
                authorities.add(new SimpleGrantedAuthority("ROLE_" + role))
            );
        }
        return authorities;
    }

    @JsonIgnore
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @JsonIgnore
    @Override
    public String getPassword() {
        return null;
    }

    @Override
    public String getUsername() {
        return loginUser != null ? loginUser.getUsername() : null;
    }

    @JsonIgnore
    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @JsonIgnore
    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @JsonIgnore
    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @JsonIgnore
    @Override
    public boolean isEnabled() {
        return true;
    }
}
