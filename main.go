package main

import (
	"flag"
	"fmt"
	"image"
	"image/draw"
	"image/png"
	"log"
	"os"

	"github.com/nfnt/resize"
	"github.com/skip2/go-qrcode"
)

func main() {
	// 定义命令行参数
	text := flag.String("text", "", "要转换为二维码的文本")
	output := flag.String("output", "qrcode.png", "输出的二维码图片文件名")
	size := flag.Int("size", 256, "二维码图片的尺寸（像素）")
	logoPath := flag.String("logo", "", "要嵌入到二维码中间的图片路径")
	logoSize := flag.Int("logo-size", 50, "logo图片的尺寸（像素），建议不超过二维码尺寸的1/3")
	border := flag.Int("border", 4, "二维码周围的空白边框大小（模块数）")
	flag.Parse()

	// 检查是否提供了文本参数
	if *text == "" {
		flag.Usage()
		os.Exit(1)
	}

	// 创建二维码
	qr, err := qrcode.New(*text, qrcode.Highest)
	if err != nil {
		log.Fatalf("生成二维码失败: %v", err)
	}
	qr.DisableBorder = true

	// 生成基础二维码图片（先写入临时文件）
	tempFile := "temp_qrcode.png"
	err = qr.WriteFile(*size, tempFile)
	if err != nil {
		log.Fatalf("生成临时二维码图片失败: %v", err)
	}
	defer os.Remove(tempFile) // 清理临时文件

	// 读取临时文件为image.Image类型
	tempImgFile, err := os.Open(tempFile)
	if err != nil {
		log.Fatalf("打开临时图片失败: %v", err)
	}
	defer tempImgFile.Close()

	qrImg, _, err := image.Decode(tempImgFile)
	if err != nil {
		log.Fatalf("解码图片失败: %v", err)
	}

	// 如果指定了border且大于0，添加额外的边框
	if *border > 0 {
		qrImg = addBorder(qrImg, *border)
	}

	// 如果指定了logo，则将其嵌入到二维码中间
	if *logoPath != "" {
		qrImg, err = embedLogo(qrImg, *logoPath, *logoSize)
		if err != nil {
			log.Fatalf("嵌入logo失败: %v", err)
		}
	}

	// 保存最终图片（使用用户指定的文件名）
	err = saveImage(qrImg, *output)
	if err != nil {
		log.Fatalf("保存图片失败: %v", err)
	}

	fmt.Printf("二维码已生成并保存为: %s\n", *output)
}

// addBorder 为图片添加白色边框
func addBorder(img image.Image, borderSize int) image.Image {
	bounds := img.Bounds()
	width := bounds.Dx()
	height := bounds.Dy()

	// 计算新图片尺寸（包括边框）
	newWidth := width + 2*borderSize
	newHeight := height + 2*borderSize

	// 创建新的RGBA图片
	newImg := image.NewRGBA(image.Rect(0, 0, newWidth, newHeight))

	// 填充白色背景
	white := image.NewUniform(image.White)
	draw.Draw(newImg, newImg.Bounds(), white, image.Point{}, draw.Src)

	// 将原图片绘制到中心
	draw.Draw(newImg,
		image.Rect(borderSize, borderSize, borderSize+width, borderSize+height),
		img,
		bounds.Min,
		draw.Src)

	return newImg
}

// embedLogo 将logo图片嵌入到二维码中间
func embedLogo(qrImage image.Image, logoPath string, logoSize int) (image.Image, error) {
	// 打开logo图片
	logoFile, err := os.Open(logoPath)
	if err != nil {
		return nil, err
	}
	defer logoFile.Close()

	// 解码logo图片
	logoImg, _, err := image.Decode(logoFile)
	if err != nil {
		return nil, err
	}

	// 调整logo大小
	resizedLogo := resize.Thumbnail(uint(logoSize), uint(logoSize), logoImg, resize.Lanczos3)

	// 创建一个可绘制的图片副本
	qrBounds := qrImage.Bounds()
	dst := image.NewRGBA(qrBounds)
	draw.Draw(dst, qrBounds, qrImage, image.Point{}, draw.Src)

	// 计算logo放置的位置（居中）
	logoBounds := resizedLogo.Bounds()
	logoWidth := logoBounds.Dx()
	logoHeight := logoBounds.Dy()
	x := (qrBounds.Dx() - logoWidth) / 2
	y := (qrBounds.Dy() - logoHeight) / 2

	// 将logo绘制到二维码中心
	draw.Draw(dst, image.Rect(x, y, x+logoWidth, y+logoHeight), resizedLogo, logoBounds.Min, draw.Over)

	return dst, nil
}

// saveImage 保存图片到文件
func saveImage(img image.Image, filePath string) error {
	outFile, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer outFile.Close()

	// 以PNG格式保存图片
	return png.Encode(outFile, img)
}
