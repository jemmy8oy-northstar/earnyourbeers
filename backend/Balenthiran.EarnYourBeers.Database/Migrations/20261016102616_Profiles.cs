using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Balenthiran.EarnYourBeers.Database.Migrations
{
    /// <inheritdoc />
    public partial class Profiles : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Profiles",
                columns: table => new
                {
                    UserId = table.Column<string>(type: "text", nullable: false),
                    Level = table.Column<int>(type: "integer", nullable: false),
                    Tally = table.Column<double>(type: "double precision", nullable: false),
                    LastSettledAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ViceEmoji = table.Column<string>(type: "character varying(16)", maxLength: 16, nullable: false),
                    OnboardedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    ReportPending = table.Column<bool>(type: "boolean", nullable: false),
                    ReportWeeklyNet = table.Column<double>(type: "double precision", nullable: false),
                    ReportOutcome = table.Column<string>(type: "character varying(24)", maxLength: 24, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Profiles", x => x.UserId);
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Profiles");
        }
    }
}
