#!/usr/bin/env python3
import math
import time
import os
import sys
import select

def clear_screen():
    os.system("clear")

def check_for_q():
    if sys.stdin in select.select([sys.stdin], [], [], 0)[0]:
        key = sys.stdin.read(1)
        if key.lower() == "q":
            return True
    return False

def rotate_point(x, y, z, angle_x, angle_y):
    y1 = y * math.cos(angle_x) - z * math.sin(angle_x)
    z1 = y * math.sin(angle_x) + z * math.cos(angle_x)
    x2 = x * math.cos(angle_y) + z1 * math.sin(angle_y)
    z2 = -x * math.sin(angle_y) + z1 * math.cos(angle_y)
    return x2, y1, z2

def main():
    vertices = [
        (-1, -1, -1), (1, -1, -1), (1, 1, -1), (-1, 1, -1),
        (-1, -1, 1), (1, -1, 1), (1, 1, 1), (-1, 1, 1)
    ]
    
    edges = [
        (0, 1), (1, 2), (2, 3), (3, 0),
        (4, 5), (5, 6), (6, 7), (7, 4),
        (0, 4), (1, 5), (2, 6), (3, 7)
    ]
    
    angle_x = 0
    angle_y = 0
    
    print("按 Q 退出")
    time.sleep(1)
    
    while True:
        clear_screen()
        print("🔄 旋轉的 3D ASCII 立方體")
        print("按 Q 退出")
        print()
        
        canvas_size = 40
        canvas = [[" " for _ in range(canvas_size)] for _ in range(canvas_size)]
        
        projected = []
        for vertex in vertices:
            x, y, z = vertex
            x_rot, y_rot, z_rot = rotate_point(x, y, z, angle_x, angle_y)
            x_proj = x_rot * 8 + 20
            y_proj = y_rot * 8 + 20
            projected.append((int(x_proj), int(y_proj)))
        
        for edge in edges:
            x1, y1 = projected[edge[0]]
            x2, y2 = projected[edge[1]]
            
            if 0 <= x1 < canvas_size and 0 <= y1 < canvas_size:
                canvas[y1][x1] = "●"
            if 0 <= x2 < canvas_size and 0 <= y2 < canvas_size:
                canvas[y2][x2] = "●"
            
            steps = max(abs(x2 - x1), abs(y2 - y1))
            if steps > 0:
                for i in range(steps + 1):
                    t = i / steps
                    x = int(x1 + t * (x2 - x1))
                    y = int(y1 + t * (y2 - y1))
                    if 0 <= x < canvas_size and 0 <= y < canvas_size:
                        if canvas[y][x] == " ":
                            canvas[y][x] = "·"
        
        for row in canvas:
            print("".join(row))
        
        print(f"角度 X: {angle_x:.2f}, Y: {angle_y:.2f}")
        
        angle_x += 0.1
        angle_y += 0.05
        
        if check_for_q():
            break
            
        time.sleep(0.1)
    
    print("\n👋 再見！")

if __name__ == "__main__":
    main()
