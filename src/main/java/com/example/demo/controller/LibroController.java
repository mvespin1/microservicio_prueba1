package com.example.demo.controller;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.controller.dto.LibroDTO;
import com.example.demo.controller.mapper.LibroMapper;
import com.example.demo.service.LibroService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/libros4")
@RequiredArgsConstructor
public class LibroController {

    private final LibroService libroService;
    private final LibroMapper libroMapper;

    @GetMapping
    public ResponseEntity<List<LibroDTO>> obtenerTodos() {
        List<LibroDTO> libros = libroService.obtenerTodos().stream()
                .map(libroMapper::toDto)
                .collect(Collectors.toList());
        return ResponseEntity.ok(libros);
    }

    @GetMapping("/{id}")
    public ResponseEntity<LibroDTO> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(libroMapper.toDto(libroService.obtenerPorId(id)));
    }

    @PostMapping
    public ResponseEntity<LibroDTO> crear(@RequestBody LibroDTO libroDTO) {
        return new ResponseEntity<>(
                libroMapper.toDto(libroService.crear(libroMapper.toEntity(libroDTO))),
                HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<LibroDTO> actualizar(@PathVariable Long id, @RequestBody LibroDTO libroDTO) {
        return ResponseEntity.ok(
                libroMapper.toDto(libroService.actualizar(id, libroMapper.toEntity(libroDTO))));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        libroService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
} 