from setuptools import setup, Extension
from Cython.Build import cythonize

# 指定源文件
source_files = ['em_cython.pyx', 'data.c','em.c','prob_functions.c']
# support source file
# 创建扩展模块
ext_module = Extension(
    'em_cython',  # 模块名
    sources=source_files,
    language='c',  # 使用 C 语言
    include_dirs=['.'],  # 包含当前目录作为头文件搜索路径
    libraries=['gsl','gslcblas'],# gsl 文件
    library_dirs=['/usr/lib/x86_64-linux-gnu']
)

# 使用 cythonize 编译并构建模块
setup(
    name='EM Algorithm Cython Module',
    ext_modules=cythonize([ext_module], language_level=3),
)
# includes only one ext_module
# including use python 3.X