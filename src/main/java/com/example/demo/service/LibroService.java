package com.example.demo.service;

import java.util.List;

import com.example.demo.model.Libro;

public interface LibroService {
    List<Libro> obtenerTodos();
    Libro obtenerPorId(Long id);
    Libro crear(Libro libro);
    Libro actualizar(Long id, Libro libro);
    void eliminar(Long id);
} 