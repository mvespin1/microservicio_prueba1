package com.example.demo.controller.mapper;

import org.springframework.stereotype.Component;

import com.example.demo.controller.dto.LibroDTO;
import com.example.demo.model.Libro;

@Component
public class LibroMapper {
    
    public LibroDTO toDto(Libro libro) {
        return new LibroDTO(
            libro.getId(),
            libro.getTitulo(),
            libro.getAutor(),
            libro.getIsbn(),
            libro.getAnioPublicacion(),
            libro.getEditorial()
        );
    }
    
    public Libro toEntity(LibroDTO libroDTO) {
        return new Libro(
            libroDTO.getId(),
            libroDTO.getTitulo(),
            libroDTO.getAutor(),
            libroDTO.getIsbn(),
            libroDTO.getAnioPublicacion(),
            libroDTO.getEditorial()
        );
    }
} 