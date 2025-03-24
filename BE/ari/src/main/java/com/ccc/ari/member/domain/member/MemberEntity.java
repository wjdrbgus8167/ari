package com.ccc.ari.member.domain.member;

import jakarta.persistence.*;
import lombok.Builder;
import lombok.Getter;
import lombok.AccessLevel;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Getter
@Entity
@Table(name = "members")
@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MemberEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "member_id")
  private Integer memberId;

  @Column(nullable = false, length = 100)
  private String nickname;

  @Column(nullable = false, length = 30)
  private String password;

  @Column(nullable = false, length = 64)
  private String email;

  @Column(nullable = true, length = 2000)
  private String profileImageUrl;

  @CreatedDate
  @Column(name = "registered_at", nullable = false, updatable = false)
  private LocalDateTime registeredAt;

  @CreatedDate
  @Column(name = "deleted_at", nullable = true, updatable = false)
  private LocalDateTime deletedAt;

  @Column(nullable = true, length = 20)
  private String instagramId;

  @Column(nullable = true, length = 100)
  private String bio;

  @Column(nullable = false, length = 10)
  private String provider;

  @Builder
  public MemberEntity(Integer memberId,String nickname,String password,String email,String profileImageUrl,String instagramId,String bio) {
    this.memberId = memberId;
    this.nickname = nickname;
    this.password = password;
    this.email = email;
    this.profileImageUrl = profileImageUrl;
    this.instagramId = instagramId;
    this.bio = bio;

  }

}