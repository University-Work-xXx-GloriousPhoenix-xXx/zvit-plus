using ZvitPlus.DAL.Models.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace ZvitPlus.DAL.Context.Configuration
{
    public class UserConfiguration : BaseEntityConfiguration<User>
    {
        public override void Configure(EntityTypeBuilder<User> builder)
        {
            base.Configure(builder);

            builder.ToTable("users");

            builder.Property(u => u.Login)
                .HasColumnName("login")
                .HasMaxLength(24)
                .IsRequired();

            builder.Property(u => u.Email)
                .HasColumnName("email")
                .HasMaxLength(64)
                .IsRequired();

            builder.Property(u => u.Password)
                .HasColumnName("password")
                .HasMaxLength(128)
                .IsRequired();

            builder.Property(u => u.Role)
                .HasColumnName("role")
                .HasMaxLength(16)
                .HasConversion<string>()
                .IsRequired();

            builder.Property(u => u.IsBanned)
                .HasColumnName("is_banned")
                .HasDefaultValue(false)
                .IsRequired();

            builder.Property(u => u.CreatedAt)
                .HasColumnName("created_at")
                .IsRequired();

            builder.Property(u => u.UpdatedAt)
                .HasColumnName("updated_at")
                .IsRequired();

            builder.HasIndex(u => u.Login)
                .HasDatabaseName("idx_users_login")
                .IsUnique();

            builder.HasIndex(u => u.Email)
                .HasDatabaseName("idx_users_email")
                .IsUnique();
        }
    }
}
