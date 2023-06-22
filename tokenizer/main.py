import os
import shutil
import tockenizer

DIST_PATH = os.getcwd() + '/dist'


def create_dist_dir():
    if not os.path.exists(DIST_PATH):
        os.makedirs(DIST_PATH)


def clear_dist_dir():
    if os.path.exists(DIST_PATH):
        shutil.rmtree(DIST_PATH)


def write_file_to_dist_dir(file_name, file_content_itt):
    with open(DIST_PATH + '/' + file_name, 'w') as file:
        for line in file_content_itt:
            file.write(line)


def main():
    tockenizer.generate_xml_file("Jack_Test.jack")


if __name__ == '__main__':
    main()
