package com.example.demo.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.example.demo.exception.LibroNotFoundException;
import com.example.demo.model.Libro;
import com.example.demo.repository.LibroRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
@Transactional
public class LibroServiceImpl implements LibroService {

    private final LibroRepository libroRepository;

    @Override
    @Transactional(readOnly = true)
    public List<Libro> obtenerTodos() {
        return libroRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Libro obtenerPorId(Long id) {
        return libroRepository.findById(id)
                .orElseThrow(() -> new LibroNotFoundException(id));
    }

    @Override
    public Libro crear(Libro libro) {
        libro.setId(null);
        return libroRepository.save(libro);
    }

    @Override
    public Libro actualizar(Long id, Libro libro) {
        if (!libroRepository.existsById(id)) {
            throw new LibroNotFoundException(id);
        }
        libro.setId(id);
        return libroRepository.save(libro);
    }

    @Override
    public void eliminar(Long id) {
        if (!libroRepository.existsById(id)) {
            throw new LibroNotFoundException(id);
        }
        libroRepository.deleteById(id);
    }
} 