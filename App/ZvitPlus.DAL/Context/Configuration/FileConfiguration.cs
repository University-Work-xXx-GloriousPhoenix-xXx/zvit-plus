using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using ZvitPlus.DAL.Models.Entities;

namespace ZvitPlus.DAL.Context.Configuration
{
    public class FileConfiguration : BaseEntityConfiguration<FileEntity>
    {
        public override void Configure(EntityTypeBuilder<FileEntity> builder)
        {
            base.Configure(builder);

            builder.ToTable("files");

            builder.Property(f => f.Name)
                .HasColumnName("name")
                .HasMaxLength(64)
                .IsRequired();

            builder.Property(f => f.AuthorId)
                .HasColumnName("author")
                .IsRequired();

            builder.Property(f => f.IsPrivate)
                .HasColumnName("is_private")
                .HasDefaultValue(false)
                .IsRequired();

            builder.Property(f => f.IsDeleted)
                .HasColumnName("is_deleted")
                .HasDefaultValue(false)
                .IsRequired();

            builder.Property(f => f.FileSize)
                .HasColumnName("file_size")
                .IsRequired();

            builder.Property(f => f.FilePath)
                .HasColumnName("file_path")
                .HasMaxLength(255)
                .IsRequired();

            builder.Property(f => f.CreatedAt)
                .HasColumnName("created_at")
                .IsRequired();

            builder.Property(f => f.UpdatedAt)
                .HasColumnName("updated_at")
                .IsRequired();

            builder.HasOne(f => f.Author)
                .WithMany(u => u.Files)
                .HasForeignKey(f => f.AuthorId)
                .HasConstraintName("fk_files_users_author_id")
                .OnDelete(DeleteBehavior.Restrict);

            builder.HasIndex(f => f.AuthorId)
                .HasDatabaseName("idx_files_author_id");
        }
    }
}
