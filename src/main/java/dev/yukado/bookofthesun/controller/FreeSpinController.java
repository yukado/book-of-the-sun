package dev.yukado.bookofthesun.controller;

import dev.yukado.bookofthesun.service.FreeSpinService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/freespins")
@RequiredArgsConstructor
public class FreeSpinController {

    private final FreeSpinService freeSpinService;

    @PostMapping("/{userId}/grant")
    public void grantFreeSpins(
            @PathVariable Long userId,
            @RequestParam int count
    ) {
        freeSpinService.grantFreeSpins(userId, count);
    }

    @GetMapping("/{userId}")
    public int getRemaining(@PathVariable Long userId) {
        return freeSpinService.getRemainingFreeSpins(userId);
    }
}
