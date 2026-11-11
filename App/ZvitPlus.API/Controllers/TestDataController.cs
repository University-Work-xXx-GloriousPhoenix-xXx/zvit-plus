using Microsoft.AspNetCore.Mvc;
using ZvitPlus.DAL.Context.DataFactory;

namespace ZvitPlus.API.Controllers
{
    [ApiController]
    [Route("api/test")]
    public class TestDataController(IDataFactory dataFactory, IWebHostEnvironment env) : ControllerBase
    {
        [HttpPost("seed")]
        public async Task<ActionResult> SeedAsync(CancellationToken ct)
        {
            if (!env.IsDevelopment())
            {
                return NotFound();
            }

            await dataFactory.InitializeAsync(ct);
            return Ok("Тестові дані створено");
        }
    }
}
