using inventory_management_system.DTOs;
using inventory_management_system.Models;
using inventory_management_system.Services;
using Microsoft.AspNetCore.Mvc;

namespace inventory_management_system.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductController : ControllerBase
{
    private readonly IProductService _service;

    public ProductController(IProductService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        return Ok(await _service.GetAll());
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> Get(int id)
    {
        var product = await _service.GetById(id);
        if (product == null) return NotFound();

        return Ok(product);
    }

    [HttpPost]
    [HttpPost]
    public async Task<IActionResult> Create(ProductDto dto)
    {
        var product = new Product
        {
            Name = dto.Name,
            Price = dto.Price,
            CategoryId = dto.CategoryId
        };

        var created = await _service.Create(product);

        return Ok(new ProductResponseDto
        {
            ProductId = created.ProductId,
            Name = created.Name,
            Price = created.Price
        });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, Product product)
    {
        var updated = await _service.Update(id, product);
        if (updated == null) return NotFound();

        return Ok(updated);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var success = await _service.Delete(id);
        if (!success) return NotFound();

        return NoContent();
    }
}